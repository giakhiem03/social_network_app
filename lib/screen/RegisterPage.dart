import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_network_project/models/Role.dart';
import 'package:social_network_project/models/User.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../ApiService/ApiService.dart';
import 'LoginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  ApiService apiService = ApiService();

  void submitForm() {
    if (formKey.currentState!.validate()) {
      User user = User(username: usernameController.text,password: passwordController.text,email: emailController.text,status: false,role: Role(roleId: 2));
      apiService.createUser(user)
          .then((new_user) {
            print(new_user);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }).catchError((error) {
        print('Error: $error');
        // Hiển thị SnackBar thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tài khoản đã có người sử dụng', // Nội dung lỗi từ server
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3), // Thời gian hiển thị
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
// backgroundColor: Colors.blue[50],
        body: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
// gradient: LinearGradient(
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
//   colors: [Colors.blue, Colors.purple],  // Đặt màu cho gradient
// ),
              image: DecorationImage(
                  image: AssetImage('assets/images/background_login.jpg'),
                  fit: BoxFit.cover),
            ),
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 78,
                      ),
                      Text(
                        'Welcome to',
                        style: GoogleFonts.chewy(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 10.0, top: 10.0),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage:
                              AssetImage('assets/images/header_logo.png'),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Go Ku',
                    style: GoogleFonts.chewy(
                        fontSize: 46, color: Colors.deepOrangeAccent),
                  ),
                  Image.asset(
                    'assets/images/center_logo.png',
                    width: 130,
                  ),
                  Card(
                    color: Colors.deepOrangeAccent,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Đăng Ký',
                                  style: GoogleFonts.dynaPuff(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 30,
                                      color: Colors.white)),
                              Image.asset(
                                'assets/images/login_gif.gif',
                                width: 50,
                                height: 50,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: usernameController,
                                    cursorColor: Colors.white,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a username';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Tài khoản',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          borderSide: BorderSide.none),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                          // Màu viền khi focus
                                          width: 1, // Độ dày viền khi focus
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            50), // Giữ góc bo tròn
                                      ),
                                      errorStyle: GoogleFonts.dynaPuff(
                                        color: Colors.white,
                                      ),
                                      fillColor: Colors.deepOrangeAccent[100],
                                      filled: true,
                                      labelStyle: GoogleFonts.dynaPuff(
                                          color: Colors.white, fontSize: 14),
                                      prefixIcon: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    obscureText: _obscureText,
                                    controller: passwordController,
                                    cursorColor: Colors.white,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Mật khẩu',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            borderSide: BorderSide.none),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                            // Màu viền khi focus
                                            width: 1, // Độ dày viền khi focus
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              50), // Giữ góc bo tròn
                                        ),
                                        fillColor: Colors.deepOrangeAccent[100],
                                        filled: true,
                                        errorStyle: GoogleFonts.dynaPuff(
                                          color: Colors.white,
                                        ),
                                        labelStyle: GoogleFonts.dynaPuff(
                                            color: Colors.white, fontSize: 14),
                                        prefixIcon: const Icon(Icons.lock,
                                            color: Colors.white),
                                        suffixIcon: IconButton(
                                            onPressed:
                                                _togglePasswordVisibility,
                                            icon: Icon(
                                              _obscureText
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.white,
                                            ))),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: emailController,
                                    cursorColor: Colors.white,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a email';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          borderSide: BorderSide.none),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                          // Màu viền khi focus
                                          width: 1, // Độ dày viền khi focus
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            50), // Giữ góc bo tròn
                                      ),
                                      fillColor: Colors.deepOrangeAccent[100],
                                      filled: true,
                                      errorStyle: GoogleFonts.dynaPuff(
                                        color: Colors.white,
                                      ),
                                      labelStyle: GoogleFonts.dynaPuff(
                                          color: Colors.white, fontSize: 14),
                                      prefixIcon: const Icon(Icons.email,
                                          color: Colors.white),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                      onPressed: submitForm,
                                      child: Text('Đăng ký',
                                          style: GoogleFonts.chewy(
                                              color: Colors.deepOrangeAccent,
                                              fontSize: 16))),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Bạn đã có tài khoản?',
                                          style: GoogleFonts.dynaPuff(
                                              fontSize: 12,
                                              color: Colors.white)),
                                      TextButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors
                                                .deepOrangeAccent, // Màu chữ của nút
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginPage()),
                                            );
                                          },
                                          child: Text(
                                            'đăng nhập',
                                            style: GoogleFonts.dynaPuff(
                                              fontSize: 12,
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.white,
                                              decorationThickness: 2.4,
                                            ),
                                          ))
                                    ],
                                  ),
                                ],
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
