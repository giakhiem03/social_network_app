import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.theme,
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // Dark/Light Mode Toggle
          ListTile(
            title: Text(
              'Mode (Dark / Light)',
              style: TextStyle(color: themeProvider.textColor, fontSize: 18),
            ),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                setState(() {
                  themeProvider.changeTheme(value);
                });
              },
            ),
          ),
          // Other settings can be added here
        ],
      ),
    );
  }
}
