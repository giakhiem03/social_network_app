import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:social_network_project/DTO/UserDTO.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

import '../models/Post.dart';
import '../models/User.dart';

class ApiService {
  final String baseUrl = '${getBaseUrl()}/api/users';

   static String getBaseUrl()  {
    if (kIsWeb) {
      // Trường hợp chạy trên web
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      // Trường hợp Android
      return 'http://10.0.2.2:8080'; // Android Emulator

    } else if (Platform.isIOS || Platform.isMacOS) {
      // Trường hợp iOS hoặc macOS (chạy Simulator)
      return 'http://127.0.0.1:8080';
    } else {
      // Trường hợp thiết bị thật (trong cùng mạng Wi-Fi)
      return 'http://${getLocalIpv4()}:8080'; // Thay '192.168.x.x' bằng IP thật
    }
  }

  static Future<String> getLocalIpv4() async {
    try {
      // Lấy danh sách các interface mạng
      List<NetworkInterface> interfaces = await NetworkInterface.list();

      for (NetworkInterface network in interfaces) {
        List<InternetAddress> addresses = await network.addresses;
        for (InternetAddress address in addresses) {
          // Kiểm tra nếu địa chỉ không phải là loopback và là địa chỉ IPv4
          if (!address.isLoopback && address.type == InternetAddressType.IPv4) {
            return address.address;
          }
        }
      }
    } catch (e) {
      print('Lỗi: $e');
    }
    return 'Không thể lấy địa chỉ IP.';
  }

  Future<User> getUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<User> login(String username, String password) async {
    UserDTO user = new UserDTO(username: username, password: password);
    print(baseUrl);
    final response = await http.post(Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson())
    );
    print(response.statusCode);
    if(response.statusCode == 200){
      return User.fromJson(jsonDecode(response.body));
    }else{
      throw Exception('Failed to login');
    }
  }

  Future<List<User>> getAllUsers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',

      },
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      print(response.statusCode);
      throw Exception('Failed to create user');
    }
  }

  Future<User> updateUser(int id, User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/delete/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  //update Image User
  Future<void> uploadImage(File imageFile, int userId) async {
    final uri = Uri.parse('${baseUrl}/updateAvatar');

    // Tạo multipart request
    var request = http.MultipartRequest('POST', uri)
      ..fields['userId'] = userId.toString()
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Hình ảnh đã được upload thành công!');
      } else {
        print('Upload thất bại! Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('Có lỗi xảy ra: $e');
    }
  }


  Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null; // Không chọn ảnh
  }
  Future<XFile?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    return pickedFile;
  }

  //
  // Future<void> uploadPost(Post post, File? postImage) async {
  //   print(post.toJson());  // In ra dữ liệu JSON của bài viết
  //
  //   final uri = Uri.parse('$baseUrl/posts');
  //   var request = http.MultipartRequest('POST', uri)
  //     ..fields['post'] = jsonEncode(post.toJson());
  //
  //   // Chỉ thêm file nếu postImage không phải null
  //   if (postImage != null) {
  //     request.files.add(await http.MultipartFile.fromPath(
  //       'postImage',
  //       postImage.path,
  //     ));
  //   }
  //
  //   try {
  //     var response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //       print('Upload thành công!');
  //       // Handle successful upload if needed
  //     } else {
  //       print('Upload thất bại: ${response.statusCode}');
  //       throw Exception('Failed to upload post');
  //     }
  //   } catch (e) {
  //     print('Lỗi khi upload: $e');
  //     throw e; // Rắc rối xảy ra thì ném ra exception để xử lý tiếp theo
  //   }
  // }

  Future<void> uploadPost(Post post, File? postImage) async {
    try {

      // Gọi API 1: Upload hình ảnh nếu có
      if (postImage != null) {
        final imageResponse = await uploadPostImage(postImage);
        if (imageResponse.statusCode == 200) {
            post.postImage = imageResponse.body;
            print("Up load ảnh thành công");// nhận đường dẫn ảnh từ response API upload
        } else {
          print('Failed to upload image: ${imageResponse.statusCode}');
          throw Exception('Failed to upload image');
        }
      }
      // Gọi API 2: Tạo bài viết với đường dẫn hình ảnh (nếu có)
      await uploadPostContent(post);

    } catch (e) {
      print('Lỗi khi upload: $e');
      throw e; // Rắc rối xảy ra thì ném ra exception để xử lý tiếp theo
    }
  }

  Future<http.Response> uploadPostImage(File postImage) async {
    var uri = Uri.parse('$baseUrl/posts/image');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('postImage', postImage.path));

    var response = await request.send();
    if (response.statusCode == 200) {

      // Đọc response để lấy tên file hoặc đường dẫn hình ảnh từ server
      return http.Response.fromStream(response);
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }

  Future<void> uploadPostContent(Post post) async {
    var uri = Uri.parse('$baseUrl/posts');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(post.toJson()),
    );

    if (response.statusCode == 200) {
      print(response.body);
      print('Upload thành công!');
      // Handle successful upload if needed
    } else {
      print('Upload thất bại: ${response.statusCode}');
      throw Exception('Failed to upload post');
    }
  }

}