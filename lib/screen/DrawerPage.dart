import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'package:social_network_project/models/DefaultAvatar.dart';
import '../models/User.dart';
import 'LoginPage.dart';
import 'ProfilePage.dart';

class DrawerPage extends StatefulWidget {
  final Function(int) onItemSelected;

  const DrawerPage({required this.onItemSelected, super.key});

  State<DrawerPage> createState() => _DrawerPage();

}

int _selectedIndex = 0;

class _DrawerPage extends State<DrawerPage> {

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context); // Lấy dữ liệu người dùng từ Provider
    final user = userProvider.user;

    return  Drawer(
      backgroundColor: Colors.grey[800],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepOrangeAccent),
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            child: Image.asset(
              'assets/images/image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black12,
            child: Column(
              children: [
                ListTile(
                  tileColor:
                  _selectedIndex == 0 ? Colors.white : Colors.grey[800],
                  leading: const Icon(
                    Icons.home,
                    color: Colors.orangeAccent,
                  ),
                  title: Text('Trang chủ',
                      style:
                      GoogleFonts.dynaPuff(color: Colors.orangeAccent)),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                    widget.onItemSelected(_selectedIndex);
                    Navigator.pop(context); // Đóng Drawer
                  },
                ),
                ListTile(
                  tileColor:
                  _selectedIndex == 1 ? Colors.white : Colors.grey[800],
                  leading: const Icon(
                    Icons.notifications,
                    color: Colors.orangeAccent,
                  ),
                  title: Text('Thông báo',
                      style:
                      GoogleFonts.dynaPuff(color: Colors.orangeAccent)),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    widget.onItemSelected(_selectedIndex);
                    Navigator.pop(context); // Đóng Drawer
                  },
                ),
                ListTile(
                  tileColor:
                  _selectedIndex == 2 ? Colors.white : Colors.grey[800],
                  leading: const badges.Badge(
                    badgeContent: Text(''),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: Colors.red,
                    ),
                    child: Icon(FeatherIcons.messageCircle, color: Colors.orangeAccent), // Biểu tượng
                  ),
                  title: Text('Tin nhắn',
                      style:
                      GoogleFonts.dynaPuff(color: Colors.orangeAccent)),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                    widget.onItemSelected(_selectedIndex);
                    Navigator.pop(context); // Đóng Drawer
                  },
                ),
                ListTile(
                  tileColor:
                  _selectedIndex == 3 ? Colors.white : Colors.grey[800],
                  leading: const Icon(
                    Icons.people,
                    color: Colors.orangeAccent,
                  ),
                  title: Text('Lời mời kết bạn',
                      style:
                      GoogleFonts.dynaPuff(color: Colors.orangeAccent)),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                    widget.onItemSelected(_selectedIndex);
                    Navigator.pop(context); // Đóng Drawer
                  },
                ),
                ListTile(
                  tileColor:
                  _selectedIndex == 4 ? Colors.white : Colors.grey[800],
                  leading: CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage( user?.image ?? Images.defaultImage),
                  ),
                  title: Text('Trang cá nhân',
                      style:
                      GoogleFonts.dynaPuff(color: Colors.orangeAccent)),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 4;
                    });
                    widget.onItemSelected(_selectedIndex);
                    Navigator.pop(context); // Đóng Drawer
                  },
                ),
                ListTile(
                  tileColor:
                  _selectedIndex == 5 ? Colors.white : Colors.grey[800],
                  leading: const Icon(
                    Icons.settings,
                    color: Colors.orangeAccent,
                  ),
                  title: Text('Cài đặt',
                      style:
                      GoogleFonts.dynaPuff(color: Colors.orangeAccent)),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 5;
                    });
                    widget.onItemSelected(_selectedIndex);
                    Navigator.pop(context); // Đóng Drawer
                  },
                ),
                ListTile(
                  tileColor:
                  _selectedIndex == 6 ? Colors.white : Colors.grey[800],
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.orangeAccent,
                  ),
                  title: Text('Đăng xuất',
                      style:
                      GoogleFonts.dynaPuff(color: Colors.orangeAccent)),
                  onTap: () {
                    user?.status=false;
                    _selectedIndex = 0;
                    Provider.of<UserProvider>(context, listen: false).logout();

                    Future.microtask(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}