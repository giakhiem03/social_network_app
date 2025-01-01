import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:social_network_project/DTO/LoginDTO.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_network_project/DTO/UpdateUserDTO.dart';
import 'package:social_network_project/models/Comments.dart';
import 'package:social_network_project/models/Friends.dart';
import 'package:social_network_project/models/Message.dart';

import '../models/EmojiUtil.dart';
import '../models/Post.dart';
import '../models/User.dart';
import '../models/Notifications.dart';

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

  Future<User> login(BuildContext context, String username, String password) async {
    LoginDTO user = LoginDTO(username: username, password: password);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        // If login is successful, parse the response body
        return User.fromJson(jsonDecode(response.body));
      } else {
        // If login fails, show a Snackbar with an error message
        _showSnackbar(context, 'Username or password incorrect');
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception('Failed to login');
    }
  }

// Function to show a Snackbar
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Snackbar duration
      ),
    );
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
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create user');
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

  String emojify(String text, {String Function(String)? fnFormat}) {
    // Xử lý đặc biệt cho <3 trước khi xử lý các emoji khác
    text = text.replaceAll('<3', '❤️');
    text = text.replaceAll(':)', '🙂');
    text = text.replaceAll(':(', '☹️');

    Iterable<Match> matches = RegExp(r':\w+').allMatches(text); // Tìm các từ dạng :emoji_name
    if (matches.isNotEmpty) {
      var result = text;
      for (Match m in matches) {
        var _e = EmojiUtil.stripColons(m.group(0));
        if (_e == null || m.group(0) == null) continue;
        if (EmojiUtil.hasName(_e)) {
          var pattern = RegExp.escape(m.group(0)!);
          var formattedCode = EmojiUtil.get(_e)!; // Lấy mã emoji từ tên
          if (fnFormat != null) {
            formattedCode = fnFormat(formattedCode);
          }
          result =
              result.replaceAll(RegExp(pattern, unicode: true), formattedCode);
        }
      }
      return result;
    }
    return text;
  }

  // Gọi API upload Post
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

  //Gọi API lấy tất cả bài post
  Future<List<Post>> getAllPosts() async {
     var uri = Uri.parse('$baseUrl/getAllPosts');
     final response = await http.get(uri);
     if(response.statusCode == 200){
       List<dynamic> posts = jsonDecode(response.body);
       return posts.map((post) => Post.fromJson(post)).toList();
     } else {
       throw Exception('Failed to get All Posts');
     }
  }

  //Gọi API khi User click tim
  Future<Post?> toggleLike(int postId, int userId) async {
     try {
       final response = await http.post(
         Uri.parse('$baseUrl/$postId/toggle-like/$userId'),
       );

       if (response.statusCode == 200) {
         print('Successfully toggled like');
         Post post = Post.fromJson(jsonDecode(response.body));
         return post; // Parse từ body (string) sang integer
         // Cập nhật UI sau khi API gọi thành công
       } else {
         print('Failed to toggle like');
         return null;
       }
     }catch (e) {
        print('Error occurred while toggling like: $e');
        return null;
      }
  }

  Future<List<Comments>> getAllCmts() async {
    try {
      var uri = Uri.parse('$baseUrl/comments');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List jsonData = json.decode(response.body);
        return jsonData.map((item) => Comments.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  Future<List<Comments>> createCmts(Comments comment, File? image) async {
    try {

      String emojifiedContent = emojify(comment.content);

      var uri = Uri.parse('$baseUrl/createCmt');

      var request = http.MultipartRequest('POST', uri);

      request.fields['post'] = '${comment.post.postId}';
      request.fields['user'] = '${comment.user.userId}';
      request.fields['content'] = emojifiedContent;
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'image', image.path));
      }
      var response = await request.send();
      print(response.statusCode);
      if(response.statusCode == 200) {
        // Convert the response body to a string and then parse it
        String responseBody = await response.stream.bytesToString();
        List jsonData = json.decode(responseBody);

        return jsonData.map((cmt) => Comments.fromJson(cmt)).toList();
      } else {
        throw Exception('Failed to load notes');
      }
    } catch(e){
      throw Exception('Failed to load users catch');
    }




    var uri = Uri.parse('$baseUrl/createCmt');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(comment.toJson()),
    );
    if (response.statusCode == 200) {
      print('Successfully comment');
      // Cập nhật UI sau khi API gọi thành công
    } else {
      print('Failed to comment');
    }
  }

  Future<List<Notifications>> getAllNotes() async{
    try {
      var uri = Uri.parse('$baseUrl/notifications');
      final response = await http.get(uri);
      if(response.statusCode == 200) {
        List jsonData = json.decode(response.body);
        return jsonData.map((note)=> Notifications.fromJson(note)).toList();
      } else {
        throw Exception('Failed to load notes');
      }
    } catch(e) {
      throw Exception('Failed to load notes catch');
    }

  }

  Future<List<User>> searchByName(String name) async {
     try {
       var uri = Uri.parse('$baseUrl/search/$name');
       final response = await http.get(uri);
       if(response.statusCode == 200) {
         List jsonData = json.decode(response.body);
         return jsonData.map((user)=> User.fromJson(user)).toList();
       } else {
         throw Exception('Failed to load notes');
       }
     }catch(e){
       throw Exception('Failed to load users catch');
     }
  }

  Future<Friends> addFriend(Friends friend) async {
    try {
      var uri = Uri.parse('$baseUrl/addFriend');
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(friend.toJson()),
      );
      if(response.statusCode == 200) {
        return Friends.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load notes');
      }
    }catch(e){
      throw Exception('Failed to load users catch');
    }
  }

  Future<List<Friends>> getAllFriends() async {
    try {
      var uri = Uri.parse('$baseUrl/getFriends');
      final response = await http.get(uri);
      if(response.statusCode == 200) {
        List jsonData = json.decode(response.body);
        return jsonData.map((friend)=> Friends.fromJson(friend)).toList();
      } else {
        throw Exception('Failed to load friends');
      }
    }catch(e){
      throw Exception('Failed to load friends catch');
    }
  }

  Future<void> removeFriend(int friendId) async{
    try {
      var uri = Uri.parse('$baseUrl/removeFriend/$friendId');
      final response = await http.delete(uri);
      if(response.statusCode == 200) {
        print("remove successful");
      } else {
        throw Exception('Failed to remove friend');
      }
    }catch(e){
    throw Exception('Failed to remove friend catch');
    }
  }

  Future<void> acceptFriend(int friendId) async{
    try {
      var uri = Uri.parse('$baseUrl/acceptFriend/$friendId');
      final response = await http.put(uri);
      if(response.statusCode == 200) {
        print("accept successful");
      } else {
        throw Exception('Failed to remove friend');
      }
    }catch(e){
      throw Exception('Failed to remove friend catch');
    }
  }

  Future<List<Message>> getAllMessage() async {
    try {
      var uri = Uri.parse('$baseUrl/messages');
      final response = await http.get(uri);
      if(response.statusCode == 200) {
        List jsonData = json.decode(response.body);
        print("Successful");
        return jsonData.map((message)=> Message.fromJson(message)).toList();
      } else {
        throw Exception('Failed to remove friend');
      }
    } catch(e){
      throw Exception('Failed to remove friend catch');
    }
  }

  Future<List<Message>> sendMessage(Message message,File? image) async {
    try {
      var uri = Uri.parse('$baseUrl/sendMessage');

        var request = http.MultipartRequest('POST', uri);

        request.fields['userSendMessage'] = '${message.userSendMessage.userId}';
        request.fields['userReceiveMessage'] = '${message.userReceiveMessage.userId}';
        request.fields['content'] = message.content;
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'image', image.path));
      }
      var response = await request.send();
        if(response.statusCode == 200) {
          // Convert the response body to a string and then parse it
          String responseBody = await response.stream.bytesToString();
          List jsonData = json.decode(responseBody);

          // Return a list of messages parsed from the JSON data
          return jsonData.map((message) => Message.fromJson(message)).toList();
        } else {
          throw Exception('Failed to load notes');
        }
    } catch(e){
      throw Exception('Failed to load users catch');
    }
  }

  Future<User> updateUser(UpdateUserDTO user, File? profileImage, File? backgroundImage) async {
    try {
      var uri = Uri.parse('$baseUrl/updateUser');

      // Tạo một multipart request
      var request = http.MultipartRequest('PUT', uri);

      request.fields['userId'] = '${user.userId}';
      request.fields['fullName'] = user.fullName;
      request.fields['email'] = user.email;
      request.fields['phoneNumber'] = user.phoneNumber;

      // Thêm các tệp hình ảnh nếu có
      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'profileImage', profileImage.path));
      }
      if (backgroundImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'backgroundImage', backgroundImage.path));
      }

      // Gửi request và nhận response
      var response = await request.send();

      // Kiểm tra trạng thái của response
      if (response.statusCode == 200) {
        // Convert StreamedResponse to normal response body
        var responseString = await response.stream.bytesToString();
        return User.fromJson(json.decode(responseString));
      } else {
        print("Failed to update user: ${response.statusCode}");
        throw Exception('Failed to update user');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('Failed to update users catch');
    }
  }
}
