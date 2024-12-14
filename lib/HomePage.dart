import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'PostPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePage createState() => _HomePage();

}

class _HomePage extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white10,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/images/image.jpg'),
                  ),
                  const SizedBox(width: 20),
                  //sử dụng GestureDetector or InkWell
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PostPage(),));
                    },
                    child: const Text('Hãy chia sẽ cảm xúc của bạn!',style: TextStyle(color: Colors.white38, fontSize: 15),),
                  )
                ],
              ),
              // const SizedBox(height: 16),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     TextButton.icon(
              //       icon: const Icon(Icons.image, color: Colors.green), // Icon với màu trắng
              //       onPressed: () {
              //         // Xử lý hành động khi nhấn nút
              //       },
              //       label: Text('Ảnh',style: GoogleFonts.chewy(color: Colors.white54)),
              //       style: TextButton.styleFrom(
              //         backgroundColor: Colors.white10
              //       )
              //     ),
              //     TextButton.icon(
              //         icon: const Icon(Icons.video_call_outlined, color: Colors.red), // Icon với màu trắng
              //         onPressed: () {
              //           // Xử lý hành động khi nhấn nút
              //         },
              //         label: Text('Video',style: GoogleFonts.chewy(color: Colors.white54)),
              //         style: TextButton.styleFrom(
              //             backgroundColor: Colors.white10
              //         )
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ],
    );
  }
}
