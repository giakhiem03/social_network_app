import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_network_project/ApiService/ApiService.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  _PostPage createState() => _PostPage();
}

class _PostPage extends State<PostPage> {
  final TextEditingController _PostInput = TextEditingController();
  File? _selectedImage;
  bool valueExist = false;
  ApiService apiService = new ApiService();

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            const Icon(
              Icons.public,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text('Công khai', style: GoogleFonts.chewy(color: Colors.white)),
            Expanded(
              // Use Expanded to push the 'data' text to the end
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.send,
                    color: valueExist ? Colors.orangeAccent : Colors.white54,
                  )
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white54,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Form nhập cảm xúc
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: TextFormField(
                  controller: _PostInput,
                  maxLines: null,
                  // Cho phép nhập nhiều dòng
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Chia sẻ cảm xúc của bạn!',
                  ),
                  style: GoogleFonts.dynaPuff(color: Colors.white70),
                  onChanged: (value) {
                    setState(() {
                      valueExist = _PostInput.text.trim().isNotEmpty;
                    });
                  },
                ),
              ),
            ),
            // Hiển thị ảnh nếu có chọn
            _selectedImage != null
                ? SizedBox(
              height: 380, // Độ cao cố định
              width: double.infinity, // Độ rộng toàn màn hình
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.contain, // Lấp đầy khung với tỷ lệ ảnh gốc
              ),
            )
                : Container(),
            // Các nút chọn ảnh
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Chọn ảnh từ thư viện"),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Chụp ảnh"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ));
  }
}
