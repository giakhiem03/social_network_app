import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = true; // Biến để lưu trạng thái chế độ

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.theme,
      body: ListView(
        children: [
          const SizedBox(height: 20,),
          // Nút đầu tiên: Chế độ sáng/tối
          ListTile(
            title: Text('Mode (Dark / Light)',style: TextStyle(color: themeProvider.textColor,fontSize: 18),),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value; // Thay đổi trạng thái
                });
                // Áp dụng chế độ sáng/tối
                themeProvider.changeTheme(isDarkMode);
              },
            ),
          ),
          // Thêm các nút khác
          // ListTile(
          //   title: const Text('Other Setting 1'),
          //   onTap: () {
          //     // Logic cho nút này
          //     print('Tapped Other Setting 1');
          //   },
          // ),
          // ListTile(
          //   title: const Text('Other Setting 2'),
          //   onTap: () {
          //     // Logic cho nút này
          //     print('Tapped Other Setting 2');
          //   },
          // ),
        ],
      ),
    );
  }
}
