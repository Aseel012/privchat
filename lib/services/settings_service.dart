import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  final String name;
  final bool blockScreenshots;
  final bool allowImageDownload;
  final bool showLastSeen;
  final bool showOnlineStatus;
  final bool notificationsEnabled;
  final String? lastConnectedSummary;

  const UserSettings({
    required this.name,
    required this.blockScreenshots,
    required this.allowImageDownload,
    required this.showLastSeen,
    required this.showOnlineStatus,
    required this.notificationsEnabled,
    required this.lastConnectedSummary,
  });

  UserSettings copyWith({
    String? name,
    bool? blockScreenshots,
    bool? allowImageDownload,
    bool? showLastSeen,
    bool? showOnlineStatus,
    bool? notificationsEnabled,
    String? lastConnectedSummary,
  }) {
    return UserSettings(
      name: name ?? this.name,
      blockScreenshots: blockScreenshots ?? this.blockScreenshots,
      allowImageDownload: allowImageDownload ?? this.allowImageDownload,
      showLastSeen: showLastSeen ?? this.showLastSeen,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastConnectedSummary: lastConnectedSummary ?? this.lastConnectedSummary,
    );
  }
}

class SettingsService {
  static const _keyName = 'user_name';
  static const _keyBlockScreenshots = 'block_screenshots';
  static const _keyAllowImageDownload = 'allow_image_download';
  static const _keyShowLastSeen = 'show_last_seen';
  static const _keyShowOnlineStatus = 'show_online_status';
  static const _keyNotifications = 'notifications_enabled';
  static const _keyLastConnectedSummary = 'last_connected_summary';

  static const UserSettings _default = UserSettings(
    name: '',
    blockScreenshots: false,
    allowImageDownload: true,
    showLastSeen: true,
    showOnlineStatus: true,
    notificationsEnabled: true,
    lastConnectedSummary: null,
  );

  static Future<UserSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserSettings(
      name: prefs.getString(_keyName) ?? _default.name,
      blockScreenshots:
          prefs.getBool(_keyBlockScreenshots) ?? _default.blockScreenshots,
      allowImageDownload:
          prefs.getBool(_keyAllowImageDownload) ?? _default.allowImageDownload,
      showLastSeen: prefs.getBool(_keyShowLastSeen) ?? _default.showLastSeen,
      showOnlineStatus:
          prefs.getBool(_keyShowOnlineStatus) ?? _default.showOnlineStatus,
      notificationsEnabled:
          prefs.getBool(_keyNotifications) ?? _default.notificationsEnabled,
      lastConnectedSummary:
          prefs.getString(_keyLastConnectedSummary) ?? _default.lastConnectedSummary,
    );
  }

  static Future<void> save(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, settings.name);
    await prefs.setBool(_keyBlockScreenshots, settings.blockScreenshots);
    await prefs.setBool(_keyAllowImageDownload, settings.allowImageDownload);
    await prefs.setBool(_keyShowLastSeen, settings.showLastSeen);
    await prefs.setBool(_keyShowOnlineStatus, settings.showOnlineStatus);
    await prefs.setBool(_keyNotifications, settings.notificationsEnabled);
    if (settings.lastConnectedSummary != null) {
      await prefs.setString(
        _keyLastConnectedSummary,
        settings.lastConnectedSummary!,
      );
    }
  }

  static Future<void> updateLastConnectedNow() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final summary =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_keyLastConnectedSummary, summary);
  }
}

