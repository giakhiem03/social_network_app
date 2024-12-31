import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:social_network_project/ApiService/ApiService.dart';
import 'package:social_network_project/models/Comments.dart';
import 'package:social_network_project/models/Post.dart';
import '../models/DefaultAvatar.dart';
import '../models/User.dart';
import 'PostPage.dart';
import 'ProfilePage.dart';

class HomeProvider extends ChangeNotifier {
  late Future<List<Post>> futurePosts;
  late Future<List<Comments>> futureCmts;
  // bool toggleComments = false;
  bool valueCmt = false;
  ApiService apiService = ApiService();
  List<TextEditingController> commentController = []; // Initialize map
// Map to track the toggle state for each post
  Map<int, bool> postCommentToggle = {};

  HomeProvider() {
    initialize();

  }

  void toggleComment(int postId) {
    // Toggle only the specific post's comment visibility
    postCommentToggle[postId] = !(postCommentToggle[postId] ?? false);
    notifyListeners();
  }

  void clearCmts(int index) {
    commentController[index].clear(); // Clear the specific controller
    futureCmts = apiService.getAllCmts(); // Làm mới danh sách bình luận
    notifyListeners();
  }


  void initialize() {
    futurePosts = apiService.getAllPosts();
    futureCmts = apiService.getAllCmts();

    futurePosts.then((posts) {
      commentController = List.generate(posts.length, (index) => TextEditingController());
      // Initialize the toggle state for each post to false (comments hidden)
      for (var post in posts) {
        postCommentToggle[post.postId!] = false;
      }
    }).catchError((error) => print("Error: $error"));
    notifyListeners();
  }

  void toggleLike(int postId, int userId) {
    apiService.toggleLike(postId, userId).then((new_post) {
      futurePosts.then((posts) {

        // Tìm bài viết có ID tương ứng và cập nhật trạng thái like
        for (var post in posts) {
          if (post.postId == postId) {
            post.reactionQuantity = new_post?.reactionQuantity;
            post.users = new_post!.users;
            break;
          }
        }
        notifyListeners(); // Chỉ cập nhật trạng thái giao diện
      });
    }).catchError((onError) {
      print('Có lỗi: $onError');
    });
  }
}


class HomePage extends StatelessWidget {


  const HomePage({ super.key});

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context); // Lấy dữ liệu người dùng từ Provider
    final user = userProvider.user;

    return Consumer<HomeProvider>(builder: (context, homeProvider, child) {
      return Column(
        children: [
          Container(
            color: Colors.white10,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                          user?.image ?? Images.defaultImage),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostPage(user: user!,),
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
          const SizedBox(height: 10),
          // FutureBuilder dùng để gọi API và hiển thị dữ liệu
          FutureBuilder<List<Post>>(
            future: homeProvider.futurePosts, // Future lấy từ hàm getAllPosts
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator()); // Hiển thị khi đang tải
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
                        margin: const EdgeInsets.only(top: 6, bottom: 6),
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                post.userUpLoad.image != null
                                    ? CircleAvatar(
                                  radius: 15,
                                  backgroundImage: NetworkImage(
                                      '${post.userUpLoad
                                          .image}'), // Dùng ảnh từ API
                                )
                                    : Container(),
                                const SizedBox(width: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        post.userUpLoad.fullName ??
                                            post.userUpLoad.username,
                                        style:
                                        const TextStyle(color: Colors.white)),
                                    Text(post.postedTime ?? '',
                                        style:
                                        const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text('${post.caption}',
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 18),
                            post.postImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image(
                                image: NetworkImage('${post.postImage}'),
                                fit: BoxFit.contain,
                                width: double.infinity,
                                alignment: Alignment.center,
                              ),
                            )
                                : Container(),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                post.users.any((user) =>
                                user.userId == user.userId)
                                    ? ElevatedButton.icon(
                                  onPressed: () {
                                    homeProvider.toggleLike(post.postId!,
                                        post.userUpLoad.userId!);
                                  },
                                  icon: const Icon(
                                    FontAwesomeIcons.solidHeart,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    "Thích",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                    WidgetStateProperty.all(
                                        Colors.white12),
                                  ),
                                )
                                    : ElevatedButton.icon(
                                  onPressed: () {
                                    homeProvider.toggleLike(post.postId!,
                                        post.userUpLoad.userId!);
                                  },
                                  icon: const Icon(
                                    FontAwesomeIcons.heart,
                                    size: 20,
                                    color: Colors.white54,
                                  ),
                                  label: const Text(
                                    "Thích",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                    WidgetStateProperty.all(
                                        Colors.white12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    homeProvider.toggleComment(post.postId!);
                                  },
                                  icon: const Icon(
                                    FontAwesomeIcons.comment,
                                    size: 20,
                                    color: Colors.white54,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                    WidgetStateProperty.all(Colors.white12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
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
                                        style: const TextStyle(
                                            color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            homeProvider.postCommentToggle[post.postId!] == true
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<List<Comments>>(
                                  future: homeProvider.futureCmts,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Có lỗi xảy ra: ${snapshot
                                                  .error}'));
                                    } else if (snapshot.hasData) {
                                      List<Comments> comments =
                                      snapshot.data!;
                                      return ListView.builder(
                                        itemCount: comments.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          Comments cmt = comments[index];
                                          if (cmt.post.postId ==
                                              post.postId) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  top: 6, bottom: 6),
                                              padding: const EdgeInsets.all(
                                                  10),
                                              decoration: BoxDecoration(
                                                color: Colors.white12,
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10),
                                              ),
                                              child: Row(
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 18,
                                                    backgroundImage:
                                                    AssetImage(
                                                        'assets/images/image.jpg'),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text(
                                                            cmt.user
                                                                .fullName ??
                                                                cmt.user
                                                                    .username,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                            cmt.content!,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          return Container();
                                        },
                                      );
                                    } else {
                                      return const Text(
                                        "Không có bình luận nào.",
                                        style: TextStyle(color: Colors.white54),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: homeProvider
                                      .commentController[index],
                                  // Use the specific controller
                                  onChanged: (value) {

                                  },
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Viết bình luận...",
                                    hintStyle: const TextStyle(
                                        color: Colors.white54),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        Comments comment = Comments(user: user!,
                                            content: homeProvider
                                                .commentController[index].text
                                                .trim(),
                                            post: post);
                                        homeProvider.apiService.createCmts(
                                            comment).then((onValue) {
                                          homeProvider.clearCmts(index);
                                        }).catchError((onError) {
                                          // Xử lý lỗi
                                          print(
                                              'Có lỗi khi gửi bình luận: $onError');
                                        });
                                      },
                                      icon: const Icon(
                                        FontAwesomeIcons.paperPlane,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : Container(),
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const Center(child: Text('No data found'));
              }
            },
          ),
        ],
      );
    });
  }
}