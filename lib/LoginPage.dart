import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_network_project/ApiService/ApiService.dart';
import 'package:social_network_project/Layout.dart';
import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  ApiService apiService = new ApiService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void submitForm() {
    if (formKey.currentState!.validate()) {
      apiService
          .login(usernameController.text, passwordController.text)
          .then((_user) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Layout(user: _user)));
      }).catchError((error) {
        String errorMessage;
        if (error.toString().contains('Invalid username or password')) {
          errorMessage = 'Sai tài khoản hoặc mật khẩu!';
        } else {
          errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại! $error';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        print('Error occurred: $error');
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
                              Text('Đăng Nhập',
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
                                    height: 16,
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
                                  ElevatedButton(
                                      onPressed: submitForm,
                                      child: Text('Đăng nhập',
                                          style: GoogleFonts.chewy(
                                              color: Colors.deepOrangeAccent,
                                              fontSize: 16))),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Bạn chưa có tài khoản?',
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
                                                      const RegisterPage()),
                                            );
                                          },
                                          child: Text(
                                            'đăng ký',
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
