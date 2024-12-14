import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_network_project/DrawerPage.dart';
import 'package:social_network_project/HomePage.dart';
import 'package:social_network_project/LoginPage.dart';

import 'models/User.dart';
// import 'package:badges/badges.dart' as badges;
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_feather_icons/flutter_feather_icons.dart';
class Layout extends StatefulWidget {
  final User user;
  const Layout({required this.user,super.key});

  _Layout createState() => _Layout();
}

class _Layout extends State<Layout> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _frmSearch = GlobalKey<ScaffoldState>();
  TextEditingController _searchInput = TextEditingController();



  int _selectedIndex = 0;

  void searchInput(value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _contentWidgets = [
      HomePage(user: widget.user,),
      const Center(child: Text('0', style: TextStyle(fontSize: 24))),
      const Center(child: Text('1', style: TextStyle(fontSize: 24))),
      const Center(child: Text('2', style: TextStyle(fontSize: 24))),
      const Center(child: Text('3', style: TextStyle(fontSize: 24))),
      const Center(child: Text('4', style: TextStyle(fontSize: 24))),
      const Center(child: Text('Settings Content', style: TextStyle(fontSize: 24))),
    ];
    if (!widget.user.status) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        // Gán key cho Scaffold
        appBar: AppBar(
          backgroundColor: Colors.white10,
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
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white, // Màu viền khi focus
                      width: 1, // Độ dày viền khi focus
                    ),
                    borderRadius: BorderRadius.circular(
                        50), // Giữ góc bo tròn
                  ),
                ),
                style: GoogleFonts.dynaPuff(color: Colors.white),
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
          user: widget.user,
        ),
        body: _contentWidgets[_selectedIndex],
      ),
    );
  }
}
