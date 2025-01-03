import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_network_project/ApiService/ApiService.dart';
import 'package:social_network_project/models/Post.dart';
import '../models/Theme.dart';
import '../models/User.dart';
import 'HomePage.dart';
import 'Layout.dart';

class PostPage extends StatefulWidget {
  final User user;

  const PostPage({required this.user, super.key});

  @override
  _PostPage createState() => _PostPage();
}

class _PostPage extends State<PostPage> {
  final TextEditingController _PostInput = TextEditingController();

  File? _selectedImage;
  bool valueExist = false;
  ApiService apiService = ApiService();

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

  // Tạo Post model để ánh xạ dữ liệu vào

  //Hàm upload bài post
  void UploadPost(HomeProvider homeProvider) async {
    try {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('HH:mm dd-MM-yyyy').format(now);
      Post post = Post(
        userUpLoad: widget.user,
        postedTime: formattedDate,
        caption: _PostInput.text,
      );

      await apiService.uploadPost(post, _selectedImage);


      setState(() {
        _PostInput.clear();
        _selectedImage = null;
      });

      homeProvider.initialize();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng bài thành công!")));
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Layout()));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xảy ra lỗi khi đăng bài!")));
      print("Lỗi khi upload: $error");
    }
  }


  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: themeProvider.textColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Icon(
              Icons.public,
              color: themeProvider.textColor,
            ),
            const SizedBox(width: 10),
            Text('Công khai', style: GoogleFonts.chewy(color: themeProvider.textColor)),
            Expanded(
              // Use Expanded to push the 'data' text to the end
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: valueExist || _selectedImage != null
                        ? Colors.orangeAccent
                        : themeProvider.textColor,
                    onPressed: valueExist || _selectedImage != null
                        ? () => UploadPost(homeProvider)
                        : null,
                  )
                ],
              ),
            ),
          ],
        ),
        backgroundColor: themeProvider.theme,
      ),
      backgroundColor: themeProvider.theme,
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
                  style: GoogleFonts.dynaPuff(color: themeProvider.textPost),
                  onChanged: (value) {
                    setState(() {
                      valueExist = _PostInput.text.trim().isNotEmpty;
                    });
                  },
                ),
              ),
            ),
            // Hiển thị ảnh nếu có chọn
            // Hiển thị ảnh nếu có chọn, kèm theo nút X để xóa ảnh
            _selectedImage != null
                ? Stack(
              children: [
                SizedBox(
                  height: 380, // Độ cao cố định
                  width: double.infinity, // Độ rộng toàn màn hình
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.contain, // Lấp đầy khung với tỷ lệ ảnh gốc
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 36,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    child: Container(
                      decoration:const BoxDecoration(
                        color: Colors.red,
                      ),
                      child: const Icon(
                        size: 30,
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
                : Container(),

            // Các nút chọn ảnh
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue, // Set the background color
                    borderRadius: BorderRadius.circular(
                        8.0), // Optional: Adds rounded corners
                  ),
                  child: IconButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(width: 20,),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue, // Set the background color
                    borderRadius: BorderRadius.circular(
                        8.0), // Optional: Adds rounded corners
                  ),
                  child: IconButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    color: themeProvider.textColor, // Icon color
                  ),
                ),
                const SizedBox(width: 30,)
              ],
            )
          ],
        ),
      ),
    ));
  }
}
