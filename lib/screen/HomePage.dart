import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_network_project/ApiService/ApiService.dart';
import 'package:social_network_project/models/Comments.dart';
import 'package:social_network_project/models/Post.dart';
import '../models/CheckURL.dart';
import '../models/DefaultAvatar.dart';
import '../models/EmojiUtil.dart';
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

  List<ScrollController> scrollControllers = [];


  File? _image;

  File? get image => _image;

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
    try {
      futurePosts =  Future.value(apiService.getAllPosts());
      futureCmts =  Future.value(apiService.getAllCmts());
      futurePosts.then((posts) {
        commentController = List.generate(posts.length, (index) => TextEditingController());
        // Initialize the toggle state for each post to false (comments hidden)
        scrollControllers = List.generate(posts.length, (index) => ScrollController());

        for (var post in posts) {
          scrollControllers[post.postId!] =  ScrollController();
          postCommentToggle[post.postId!] = false;
        }
      }).catchError((error){print("Error: $error");} );
      notifyListeners();
    }catch(e) {
      print(e);
    }

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

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        _image = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  bool _showEmojiPicker = false;
  bool get showEmojiPicker => _showEmojiPicker;

  void toggleEmojiPicker() {
    _showEmojiPicker = !_showEmojiPicker;
    notifyListeners();
  }

  void openEmoji(TextEditingController controller,Emoji emoji) {
    controller.text += emoji.emoji;
    notifyListeners();
  }

  void handleBackspace(TextEditingController messageController) {
    messageController.text = messageController.text.characters.skipLast(1).toString();
    notifyListeners();
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

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Chụp ảnh'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn ảnh từ thư viện'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void clearImage() {
    _image = null;
    notifyListeners(); // Cập nhật lại UI
  }

  void sendComment(Comments comment) {
    if (comment.content.isNotEmpty && _image == null) {
      apiService.createCmts(comment, null).then((onValue) {
        futureCmts = Future.value(onValue);
        notifyListeners();
      }).catchError((onError) {
        print('Có lỗi khi gửi bình luận: $onError');
      });
    } else if(_image != null){
      apiService.createCmts(comment, _image).then((onValue) {
        futureCmts = Future.value(onValue);
        _image = null;
        notifyListeners();
      }).catchError((onError) {
        print('Có lỗi khi gửi bình luận: $onError');
      });
    }
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
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
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
                                    Text(post.postedTime,
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
                                ? Container(
                              constraints: const BoxConstraints(
                                maxHeight: 300
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder(
                                      future: homeProvider.futureCmts,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
                                        } else if (snapshot.hasData) {
                                          List<Comments> comments = snapshot.data!;

                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            homeProvider.scrollControllers[post.postId!].
                                            jumpTo(homeProvider.scrollControllers[post.postId!].
                                            position.maxScrollExtent * 1.4);
                                          });
                                          return Container(
                                            constraints: const BoxConstraints(
                                              maxHeight: 220
                                            ),
                                            child: ListView.builder(
                                              controller: homeProvider.scrollControllers[post.postId!],
                                              itemCount: comments.length,
                                              shrinkWrap: true,
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                Comments cmt = comments[index];
                                                if (cmt.post.postId == post.postId) {
                                                  return Container(
                                                    margin: const EdgeInsets.only(top: 6, bottom: 6),
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white12,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                      child: Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 18,
                                                            backgroundImage: NetworkImage('${cmt.user.image}'),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          checkUrl(cmt.content)
                                                              ? Expanded(
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                // Tên người dùng
                                                                Text(
                                                                  cmt.user.fullName ?? cmt.user.username,
                                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                ),
                                                                const SizedBox(width: 10), // Tạo khoảng cách giữa tên người dùng và ảnh
                                                                // Hình ảnh trong comment
                                                                ClipRRect(
                                                                  borderRadius: BorderRadius.circular(8),
                                                                  child: Image.network(
                                                                    cmt.content,
                                                                    height: 120,
                                                                    fit: BoxFit.contain,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                              : Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                // Tên người dùng
                                                                Text(
                                                                  cmt.user.fullName ?? cmt.user.username,
                                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                ),
                                                                const SizedBox(height: 2),
                                                                // Nội dung bình luận
                                                                Text(
                                                                  cmt.content,
                                                                  style: const TextStyle(color: Colors.white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )

                                                  );
                                                }
                                                return Container();
                                              },
                                            ),
                                          )
                                          ;
                                        } else {
                                          return const Text(
                                            "Không có bình luận nào.",
                                            style: TextStyle(color: Colors.white54),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    homeProvider.image != null
                                        ? Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 100,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: FileImage(homeProvider.image!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                    size: 30,
                                                  ),
                                                  onPressed: () {
                                                    homeProvider.clearImage();
                                                  },
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    Comments comment = Comments(
                                                      user: user!,
                                                      content: homeProvider.commentController[index].text.trim(),
                                                      post: post,
                                                    );
                                                    homeProvider.sendComment(comment);
                                                    homeProvider.clearCmts(index);
                                                  },
                                                  icon: const Icon(
                                                    FontAwesomeIcons.paperPlane,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                        : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: homeProvider.commentController[index],
                                        onChanged: (text) {
                                          homeProvider.commentController[index].value = homeProvider.commentController[index].value.copyWith(
                                            text: homeProvider.emojify(text),
                                            selection: TextSelection.collapsed(offset: text.length),
                                          );
                                        },
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: "Viết bình luận...",
                                          hintStyle: const TextStyle(color: Colors.white54),
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: homeProvider.toggleEmojiPicker,
                                                icon: const Icon(
                                                  Icons.insert_emoticon,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.camera_alt, color: Colors.white),
                                                onPressed: () {
                                                  homeProvider._showImageOptions(context);
                                                },
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  Comments comment = Comments(
                                                    user: user!,
                                                    content: homeProvider.commentController[index].text.trim(),
                                                    post: post,
                                                  );
                                                  homeProvider.sendComment(comment);
                                                  homeProvider.clearCmts(index);
                                                },
                                                icon: const Icon(
                                                  FontAwesomeIcons.paperPlane,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                : Container(),
                            if (homeProvider.showEmojiPicker)
                              EmojiPicker(
                                textEditingController: homeProvider.commentController[index],
                                onEmojiSelected: (category,  emoji) {
                                  homeProvider.openEmoji(homeProvider.commentController[index],emoji);
                                },
                                onBackspacePressed: () {
                                  homeProvider.handleBackspace(homeProvider.commentController[index]);
                                },
                                config: const Config(
                                  height: 256,
                                  checkPlatformCompatibility: true,
                                  viewOrderConfig: const ViewOrderConfig(
                                    top: EmojiPickerItem.categoryBar,
                                    middle: EmojiPickerItem.emojiView,
                                    bottom: EmojiPickerItem.searchBar,
                                  ),
                                  // Loại bỏ skinToneConfig
                                  categoryViewConfig: const CategoryViewConfig(),
                                  bottomActionBarConfig: const BottomActionBarConfig(),
                                  searchViewConfig: const SearchViewConfig(),
                                ),
                              ),
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

  bool checkUrl(String content) {
    return CheckURL.isValidUrl(content);
  }

}
