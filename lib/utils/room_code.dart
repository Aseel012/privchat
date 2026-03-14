import 'dart:math';

String generateRoomCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
  );
}

