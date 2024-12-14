import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:social_network_project/ApiService/ApiService.dart';
import 'package:social_network_project/test2.dart';

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  // ApiService apiService = new ApiService();
  // Hàm chọn ảnh từ thư viện hoặc máy ảnh
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Hàm upload ảnh lên server
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng chọn một ảnh trước!")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });
    try {
      final uri = Uri.parse('http://10.0.2.2:8080/api/users/updateAvatar');
      final request = http.MultipartRequest('POST', uri)
        ..fields['userId'] = '6' // Thay bằng ID người dùng thực tế
        ..files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tải ảnh lên thành công!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tải ảnh lên thất bại! Mã lỗi: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Có lỗi xảy ra: $e")),
      );
    } finally {
      setState(() {
        _isUploading = true;
        // _isUploading = false; true
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cập nhật ảnh đại diện"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hiển thị ảnh được chọn
            CircleAvatar(
              radius: 80,
              backgroundImage:
              _selectedImage != null ? FileImage(_selectedImage!) : null,
              child: _selectedImage == null
                  ? Icon(Icons.person, size: 80)
                  : null,
            ),
            SizedBox(height: 16),
            // Nút chọn ảnh từ thư viện
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library),
              label: Text("Chọn ảnh từ thư viện"),
            ),
            // Nút chọn ảnh từ máy ảnh
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera_alt),
              label: Text("Chụp ảnh"),
            ),
            SizedBox(height: 16),
            // Nút tải ảnh lên
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              child: _isUploading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Tải ảnh lên"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Test2(userId: 6)));
              },
              child: Text('Qua test 2'),
            ),
          ],
        ),
      ),
    );
  }
}
