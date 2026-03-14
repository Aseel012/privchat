const { createServer } = require("http");
const { Server } = require("socket.io");

const PORT = process.env.PORT || 3000;
const httpServer = createServer();

const io = new Server(httpServer, {
  cors: { origin: "*", methods: ["GET", "POST"] },
  pingTimeout: 60000,
  pingInterval: 25000,
});

// roomCode -> { members: Set of socket ids }
const rooms = {};

io.on("connection", (socket) => {
  console.log(`[+] Connected: ${socket.id}`);

  // Host creates room
  socket.on("create_room", (room, callback) => {
    if (rooms[room]) {
      // Room already exists, just rejoin (page refresh etc)
      rooms[room].members.add(socket.id);
    } else {
      rooms[room] = { members: new Set([socket.id]) };
    }
    socket.join(room);
    socket.roomCode = room;
    console.log(`[ROOM] Created: ${room} | Rooms:`, Object.keys(rooms));
    if (callback) callback({ success: true });
  });

  // Guest joins room
  socket.on("join_room", (room, callback) => {
    console.log(`[JOIN] Attempt: ${room} | Rooms:`, Object.keys(rooms));

    if (!rooms[room]) {
      callback({ success: false, error: "Room not found. Ask your friend to open the app first." });
      return;
    }
    if (rooms[room].members.size >= 2) {
      callback({ success: false, error: "Room is full." });
      return;
    }

    rooms[room].members.add(socket.id);
    socket.join(room);
    socket.roomCode = room;

    socket.to(room).emit("user_joined");
    callback({ success: true });
    console.log(`[JOIN] Success: ${room}`);
  });

  // Message
  socket.on("send_message", (data) => {
    socket.to(data.room).emit("receive_message", data.message);
  });

  // Disconnect
  socket.on("disconnect", () => {
    const room = socket.roomCode;
    if (room && rooms[room]) {
      rooms[room].members.delete(socket.id);
      if (rooms[room].members.size === 0) {
        delete rooms[room];
        console.log(`[ROOM] Deleted empty room: ${room}`);
      } else {
        socket.to(room).emit("user_left");
      }
    }
    console.log(`[-] Disconnected: ${socket.id}`);
  });
});

httpServer.listen(PORT, () => console.log(`Server running on port ${PORT}`));