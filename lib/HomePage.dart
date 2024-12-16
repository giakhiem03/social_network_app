import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:social_network_project/ApiService/ApiService.dart';
import 'package:social_network_project/models/Post.dart';

import 'PostPage.dart';
import 'models/User.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({required this.user, super.key});

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late Future<List<Post>> futurePosts;
  ApiService apiService = ApiService();
  @override
  void initState() {
    super.initState();
    futurePosts = apiService.getAllPosts();
    futurePosts.then((value) => print("Posts fetched successfully: $value"))
        .catchError((error) => print("Error: $error"));
  }

  void toggleLike(int postId, int userId) {
    Future reaction = apiService.toggleLike(postId, userId);
    reaction
        .then((onValue){
          setState(() {
            futurePosts = apiService.getAllPosts();
          });
    })
        .catchError((onError){
          print('có lỗi: $onError');
    });
  }
  // void toggleLike(int postId, int userId) {
  //   setState(() {
  //     // Tạm thời cập nhật UI trước (Optimistic UI)
  //     futurePosts = futurePosts.then((posts) {
  //       posts.forEach((post) {
  //         if (post.postId == postId) {
  //           if (post.users.any((user) => user.userId == userId)) {
  //             // Bỏ thích
  //             post.users.removeWhere((user) => user.userId == userId);
  //             post.reactionQuantity = (post.reactionQuantity ?? 0) - 1;
  //           } else {
  //             // Thích
  //             post.users.add(widget.user);
  //             post.reactionQuantity = (post.reactionQuantity ?? 0) + 1;
  //           }
  //         }
  //       });
  //       return posts;
  //     });
  //   });

  //   // Gửi yêu cầu API để đồng bộ với server
  //   apiService.toggleLike(postId, userId).catchError((error) {
  //     print('Có lỗi: $error');
  //     // Xử lý nếu cần khôi phục trạng thái
  //   });
  // }

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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostPage(user: widget.user),
                        ),
                      );
                    },
                    child: const Text(
                      'Hãy chia sẽ cảm xúc của bạn!',
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        // FutureBuilder dùng để gọi API và hiển thị dữ liệu
        FutureBuilder<List<Post>>(
          future: futurePosts, // Future lấy từ hàm getAllPosts
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Hiển thị khi đang tải
            } else if (snapshot.hasError) {
              return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              List<Post> posts = snapshot.data!;

              // Nếu có dữ liệu, hiển thị danh sách bài post
              return Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    Post post = posts[index];
                    return Container(
                      color: Colors.white10,
                      margin:const EdgeInsets.only(top: 6,bottom: 6),
                      padding:const EdgeInsets.only(left: 20,right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              post.userUpLoad.image != null ?
                              CircleAvatar(
                                radius: 15,
                                backgroundImage: NetworkImage(
                                    '${post.userUpLoad.image}'
                                ), // Dùng ảnh từ API
                              ) : Container(),
                              const SizedBox(width: 18),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.userUpLoad.fullName ?? post.userUpLoad.username,
                                      style: const TextStyle(color: Colors.white)),
                                  Text(post.postedTime ?? '',
                                      style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text('${post.caption}', style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 18),
                          post.postImage != null ?
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image(
                              image: NetworkImage('${post.postImage}'),
                              fit: BoxFit.contain,
                              width: double.infinity,
                              alignment: Alignment.center,
                            ),
                          ) : Container() ,
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              post.users.any((user) => user.userId == widget.user.userId) ?
                              ElevatedButton.icon(
                                onPressed: (){toggleLike(post.postId!,post.userUpLoad.userId!);} ,
                                icon: const Icon(
                                  FontAwesomeIcons.solidHeart,
                                  size: 20,
                                  color: Colors.red,
                                )  ,
                                label: const Text(
                                  "Thích",
                                  style: TextStyle(color: Colors.white54),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(Colors.white12),
                                ),
                              ) :
                              ElevatedButton.icon(
                                onPressed: (){toggleLike(post.postId!,post.userUpLoad.userId!);} ,
                                icon: const Icon(
                                  FontAwesomeIcons.heart,
                                  size: 20,
                                  color: Colors.white54,
                                )  ,
                                label: const Text(
                                  "Thích",
                                  style: TextStyle(color: Colors.white54),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(Colors.white12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  FontAwesomeIcons.comment,
                                  size: 20,
                                  color: Colors.white54,
                                ),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(Colors.white12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white12, // Đặt màu nền cho Container
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.solidHeart,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${post.reactionQuantity}',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,)
                        ],
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(child: Text('Không có dữ liệu'));
            }
          },
        ),
      ],
    );
  }
}
