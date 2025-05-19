import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Keys for SharedPreferences
  static const String _keyEnableFlash = 'enableFlash';
  static const String _keyEnableSound = 'enableSound';
  static const String _keyEnableVibration = 'enableVibration';
  static const String _keyDarkMode = 'darkMode';
  static const String _keySaveHistory = 'saveHistory';

  // Local state variables
  bool _enableFlash = false;
  bool _enableSound = true;
  bool _enableVibration = true;
  bool _darkMode = false;
  bool _saveHistory = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableFlash = prefs.getBool(_keyEnableFlash) ?? false;
      _enableSound = prefs.getBool(_keyEnableSound) ?? true;
      _enableVibration = prefs.getBool(_keyEnableVibration) ?? true;
      _darkMode = prefs.getBool(_keyDarkMode) ?? false;
      _saveHistory = prefs.getBool(_keySaveHistory) ?? true;
    });
  }

  Future<void> _updatePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _clearScanHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan history cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: _darkMode ? Colors.grey[900] : theme.primaryColor,
        iconTheme: IconThemeData(
          color: _darkMode ? Colors.white : theme.primaryIconTheme.color,
        ),
        titleTextStyle: TextStyle(
          color: _darkMode
              ? Colors.white
              : theme.primaryTextTheme.titleLarge?.color,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Container(
        color: _darkMode ? Colors.black : Colors.white,
        child: ListView(
          children: [
            const SizedBox(height: 8),

            // Flash Toggle
            SwitchListTile(
              title: const Text('Enable Flash'),
              subtitle:
                  const Text('Turn camera flashlight on/off during scanning'),
              value: _enableFlash,
              onChanged: (val) {
                setState(() => _enableFlash = val);
                _updatePreference(_keyEnableFlash, val);
              },
              secondary: const Icon(Icons.flash_on),
              activeColor: Colors.blueAccent,
              tileColor: _darkMode ? Colors.grey[850] : null,
            ),

            const Divider(height: 1),

            // Sound Toggle
            SwitchListTile(
              title: const Text('Enable Sound'),
              subtitle: const Text('Play a beep sound after a successful scan'),
              value: _enableSound,
              onChanged: (val) {
                setState(() => _enableSound = val);
                _updatePreference(_keyEnableSound, val);
              },
              secondary: const Icon(Icons.volume_up),
              activeColor: Colors.blueAccent,
              tileColor: _darkMode ? Colors.grey[850] : null,
            ),

            const Divider(height: 1),

            // Vibration Toggle
            SwitchListTile(
              title: const Text('Enable Vibration'),
              subtitle: const Text('Vibrate device after a successful scan'),
              value: _enableVibration,
              onChanged: (val) {
                setState(() => _enableVibration = val);
                _updatePreference(_keyEnableVibration, val);
              },
              secondary: const Icon(Icons.vibration),
              activeColor: Colors.blueAccent,
              tileColor: _darkMode ? Colors.grey[850] : null,
            ),

            const Divider(height: 1),

            // Save History Toggle
            SwitchListTile(
              title: const Text('Save Scan History'),
              subtitle: const Text('Store scanned codes in history list'),
              value: _saveHistory,
              onChanged: (val) {
                setState(() => _saveHistory = val);
                _updatePreference(_keySaveHistory, val);
              },
              secondary: const Icon(Icons.history),
              activeColor: Colors.blueAccent,
              tileColor: _darkMode ? Colors.grey[850] : null,
            ),

            const Divider(height: 1),

            // Clear History Button
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Clear Scan History'),
              subtitle: const Text('Remove all saved scan entries'),
              onTap: _clearScanHistory,
              tileColor: _darkMode ? Colors.grey[850] : null,
            ),

            const Divider(height: 1),

            // Dark Mode Toggle
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme throughout the app'),
              value: _darkMode,
              onChanged: (val) {
                setState(() => _darkMode = val);
                _updatePreference(_keyDarkMode, val);
              },
              secondary: const Icon(Icons.brightness_6),
              activeColor: Colors.blueAccent,
              tileColor: _darkMode ? Colors.grey[850] : null,
            ),

            const Divider(height: 1),

            // About Section (optional)
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('App version, developer info, licenses'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'QR Scanner',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 My Company',
                );
              },
              tileColor: _darkMode ? Colors.grey[850] : null,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
