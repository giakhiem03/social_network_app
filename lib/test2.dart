import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/User.dart';

class Test2 extends StatelessWidget {
  final int userId;

  Test2({required this.userId});

  Future<User> fetchUser(int userId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/users/$userId'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User>(
        future: fetchUser(userId),
        builder: (context, snapshot) {
          print('data la : ${snapshot.data}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Icon(Icons.error);
          } else if (snapshot.hasData) {
            return Column(
              children: [
                Image.network(
                  snapshot.data!.image!, // Safe unwrapping with null-check
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                Text(snapshot.data!.fullName ?? 'Unknown'),
              ],
            );
          } else {
            return Icon(Icons.error);
          }
        },
      ),
    );
  }
}