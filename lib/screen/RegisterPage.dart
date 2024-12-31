import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_network_project/models/Role.dart';
import 'package:social_network_project/models/User.dart';
import 'package:http/http.dart' as http;

import '../ApiService/ApiService.dart';
import 'LoginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: RegisterForm(),
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

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isPasswordHidden = true;
  bool _isLoading = false;
  ApiService apiService = ApiService();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  void _submitForm() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      FocusScope.of(context).unfocus(); // Hide keyboard

      User user = User(
          username: usernameController.text,
          password: passwordController.text,
          email: emailController.text,
          status: false,
          role: Role(roleId: 2));

      try {
        final newUser = await apiService.createUser(user);
        print(newUser);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const LoginPage()));
      } catch (error) {
        print('Error: $error');
        String errorMessage = 'Đã xảy ra lỗi, vui lòng thử lại sau.';
        if (error is http.Response) {
          // Assuming the server returns error details in the response body
          try {
            final errorBody = jsonDecode(error.body);
            errorMessage = errorBody['message'] ?? 'Lỗi không xác định.';
          } catch (e) {
            errorMessage = 'Lỗi không xác định.';
          }
        } else if (error is SocketException) {
          errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepOrangeAccent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên đăng nhập';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Tài khoản',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(50),
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
                    obscureText: _isPasswordHidden,
                    controller: passwordController,
                    cursorColor: Colors.white,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        fillColor: Colors.deepOrangeAccent[100],
                        filled: true,
                        errorStyle: GoogleFonts.dynaPuff(
                          color: Colors.white,
                        ),
                        labelStyle: GoogleFonts.dynaPuff(
                            color: Colors.white, fontSize: 14),
                        prefixIcon:
                        const Icon(Icons.lock, color: Colors.white),
                        suffixIcon: IconButton(
                            onPressed: _togglePasswordVisibility,
                            icon: Icon(
                              _isPasswordHidden
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
                        return 'Vui lòng nhập email';
                      }
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      fillColor: Colors.deepOrangeAccent[100],
                      filled: true,
                      errorStyle: GoogleFonts.dynaPuff(
                        color: Colors.white,
                      ),
                      labelStyle: GoogleFonts.dynaPuff(
                          color: Colors.white, fontSize: 14),
                      prefixIcon: const Icon(Icons.email, color: Colors.white),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.deepOrangeAccent,
                      )
                          : Text('Đăng ký',
                          style: GoogleFonts.chewy(
                              color: Colors.deepOrangeAccent,
                              fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Bạn đã có tài khoản?',
                          style: GoogleFonts.dynaPuff(
                              fontSize: 12, color: Colors.white)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text(
                          'Đăng nhập',
                          style: GoogleFonts.dynaPuff(
                            fontSize: 12,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            decorationThickness: 2.4,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}