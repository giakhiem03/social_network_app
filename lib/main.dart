import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_network_project/screen/HomePage.dart';
import 'package:social_network_project/screen/ListSearchPage.dart';
import 'package:social_network_project/screen/MessagePage.dart';
import 'package:social_network_project/screen/ProfilePage.dart';
import 'models/Theme.dart';
import 'screen/LoginPage.dart';

void main() {

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
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
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
