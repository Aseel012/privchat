import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserSettings? _settings;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await SettingsService.load();
    _nameController.text = loaded.name;
    if (!mounted) return;
    setState(() => _settings = loaded);
  }

  Future<void> _update(UserSettings newSettings) async {
    setState(() => _settings = newSettings);
    await SettingsService.save(newSettings);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = _settings;

    return Scaffold(
      backgroundColor: const Color(0xFF211D2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF211D2D),
        iconTheme: const IconThemeData(color: Color(0xFFF2DFD8)),
        title: const Text(
          'Settings',
          style: TextStyle(color: Color(0xFFF2DFD8)),
        ),
        centerTitle: true,
      ),
      body: s == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Color(0xFFF2DFD8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Your name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF353839),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) =>
                      _update(s.copyWith(name: value.trim())),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Privacy & Safety',
                  style: TextStyle(
                    color: Color(0xFFF2DFD8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                SwitchListTile(
                  value: s.blockScreenshots,
                  onChanged: (value) =>
                      _update(s.copyWith(blockScreenshots: value)),
                  title: const Text(
                    'Block screenshots of chat',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Prevents screenshots on supported devices',
                    style: TextStyle(color: Colors.white54),
                  ),
                  activeColor: theme.colorScheme.secondary,
                ),
                SwitchListTile(
                  value: s.allowImageDownload,
                  onChanged: (value) =>
                      _update(s.copyWith(allowImageDownload: value)),
                  title: const Text(
                    'Allow image downloads',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'If off, images (when supported) cannot be saved',
                    style: TextStyle(color: Colors.white54),
                  ),
                  activeColor: theme.colorScheme.secondary,
                ),
                SwitchListTile(
                  value: s.showLastSeen,
                  onChanged: (value) =>
                      _update(s.copyWith(showLastSeen: value)),
                  title: const Text(
                    'Show last seen',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Controls whether last connected time is shown',
                    style: TextStyle(color: Colors.white54),
                  ),
                  activeColor: theme.colorScheme.secondary,
                ),
                SwitchListTile(
                  value: s.showOnlineStatus,
                  onChanged: (value) =>
                      _update(s.copyWith(showOnlineStatus: value)),
                  title: const Text(
                    'Show online status',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Controls whether the online indicator is visible',
                    style: TextStyle(color: Colors.white54),
                  ),
                  activeColor: theme.colorScheme.secondary,
                ),
                SwitchListTile(
                  value: s.notificationsEnabled,
                  onChanged: (value) =>
                      _update(s.copyWith(notificationsEnabled: value)),
                  title: const Text(
                    'Notifications',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Prepare app for push/local notifications',
                    style: TextStyle(color: Colors.white54),
                  ),
                  activeColor: theme.colorScheme.secondary,
                ),

                const SizedBox(height: 24),
                const Text(
                  'History',
                  style: TextStyle(
                    color: Color(0xFFF2DFD8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF353839),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Last connected',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        s.lastConnectedSummary ?? 'No chats yet',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  'About',
                  style: TextStyle(
                    color: Color(0xFFF2DFD8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enzo is a privacy-focused 1:1 chat app built as a project by a 2nd year student. '
                  'Chats are temporary and rooms are closed as soon as someone leaves, '
                  'so your conversations are not stored on the server.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
    );
  }
}

