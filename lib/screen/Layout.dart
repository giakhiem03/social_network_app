import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_network_project/screen/DrawerPage.dart';
import 'package:social_network_project/screen/ListSearchPage.dart';

import '../models/Theme.dart';
import '../models/User.dart';
import 'FriendRequestPage.dart';
import 'HomePage.dart';
import 'LoginPage.dart';
import 'ListMessagePage.dart';
import 'NotificationPage.dart';
import 'ProfilePage.dart';
import 'SettingsPage.dart';

class Layout extends StatefulWidget {

  const Layout({super.key});

  @override
  State<Layout> createState() => _Layout();
}

class _Layout extends State<Layout> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _frmSearch = GlobalKey<ScaffoldState>();
  final TextEditingController _searchInput = TextEditingController();

  int _selectedIndex = 0;

  void searchInput(value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context); // Lấy dữ liệu người dùng từ Provider
    final user = userProvider.user;

    final themeProvider = Provider.of<ThemeProvider>(context);

    final List<Widget> _contentWidgets = [
      const HomePage(),
      NotificationPage(),
      const ListMessagePage(),
      const FriendRequestPage(),
      ProfilePage(),
      const SettingsPage(),
    ];
    // if (user!.status==false) {
    //   Future.microtask(() {
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => const LoginPage()),
    //     );
    //   });
    // }
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        // Gán key cho Scaffold
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: themeProvider.theme,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.deepOrangeAccent),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer(); // Mở Drawer
            },
          ),
          title: Form(
              key: _frmSearch,
              child: TextFormField(
                controller: _searchInput,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: IconButton(onPressed:()=>Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListSearchPage(userSend: user!,name: _searchInput.text)
                  )),
                      icon: const Icon(Icons.search)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: themeProvider.textColor, // Màu viền khi focus
                      width: 1, // Độ dày viền khi focus
                    ),
                    borderRadius: BorderRadius.circular(
                        50), // Giữ góc bo tròn
                  ),
                ),
                style: TextStyle(color: themeProvider.textColor),
                onChanged: searchInput,
            )
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1), // Chiều cao border
            child: Container(
              color: Colors.grey, // Màu của border
              height: 0.7,
            ),
          ),
        ),
        backgroundColor: Colors.black,
        drawer: DrawerPage(
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        body: _contentWidgets[_selectedIndex],
      ),
    );
  }
}
