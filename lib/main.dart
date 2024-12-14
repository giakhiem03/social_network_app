import 'package:flutter/material.dart';
import 'package:social_network_project/DrawerPage.dart';
import 'package:social_network_project/HomePage.dart';
import 'package:social_network_project/test2.dart';
import 'LoginPage.dart';
import 'models/test.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home:  const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
