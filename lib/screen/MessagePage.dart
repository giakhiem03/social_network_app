import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_network_project/models/CheckURL.dart';

import '../ApiService/ApiService.dart';
import '../models/EmojiUtil.dart';
import '../models/Message.dart';
import '../models/User.dart';

class MessageProvider extends ChangeNotifier {
  ApiService apiService = ApiService();
  late Future<List<Message>> futureMessage;
  bool _showEmojiPicker = false;

  File? _image;

  File? get image => _image;

  MessageProvider() {
    initialize();
  }
  bool get showEmojiPicker => _showEmojiPicker;
  void initialize() {
    futureMessage = apiService.getAllMessage();
  }

  bool isUrl(String content) {
    Uri? uri = Uri.tryParse(content);
    return uri != null && uri.hasScheme;
  }

  void sendMessage(User you, User yourFriend, String content) {
    if (content.isNotEmpty && _image == null) {
      String emojifiedContent = emojify(content);

      Message message = Message(
        userSendMessage: you,
        userReceiveMessage: yourFriend,
        content: emojifiedContent,
      );

      apiService.sendMessage(message,null).then((messages) {
        futureMessage =  Future.value(messages);
        notifyListeners();
      }).catchError((onError) {
        print(onError);
      });
    } else if (_image != null){
      Message message = Message(
        userSendMessage: you,
        userReceiveMessage: yourFriend,
        content: "",
      );

      apiService.sendMessage(message,_image).then((messages) {
        futureMessage = Future.value(messages);
        _image = null;
        notifyListeners();
      }).catchError((onError) {
        print(onError);
      });
    }
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

  void toggleEmojiPicker() {
    _showEmojiPicker = !_showEmojiPicker;
    notifyListeners();
  }

  void openEmoji(TextEditingController controller, Emoji emoji) {
    controller.text += emoji.emoji;
    notifyListeners();
  }

  void handleBackspace(TextEditingController messageController) {
    messageController.text = messageController.text.characters.skipLast(1).toString();
    notifyListeners();
  }

  String emojify(String text, {String Function(String)? fnFormat}) {
    text = text.replaceAll('<3', '❤️');
    text = text.replaceAll(':)', '🙂');
    text = text.replaceAll(':(', '☹️');

    Iterable<Match> matches = RegExp(r':\w+').allMatches(text);
    if (matches.isNotEmpty) {
      var result = text;
      for (Match m in matches) {
        var _e = EmojiUtil.stripColons(m.group(0));
        if (_e == null || m.group(0) == null) continue;
        if (EmojiUtil.hasName(_e)) {
          var pattern = RegExp.escape(m.group(0)!);
          var formattedCode = EmojiUtil.get(_e)!;
          if (fnFormat != null) {
            formattedCode = fnFormat(formattedCode);
          }
          result = result.replaceAll(RegExp(pattern, unicode: true), formattedCode);
        }
      }
      return result;
    }
    return text;
  }

  void clearImage() {
    _image = null;
    notifyListeners(); // Cập nhật lại UI
  }

}

class MessagePage extends StatelessWidget {
  User you;
  User yourFriend;

  MessagePage({required this.you, required this.yourFriend, super.key});

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool checkUrl(String content) {
    return CheckURL.isValidUrl(content);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white10,
        body: Consumer<MessageProvider>(
          builder: (context, messageProvider, child) {
            messageProvider.initialize();
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white24, width: 2.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const BackButton(),
                      ClipOval(
                        child: Image.network(
                          '${yourFriend.image}',
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${yourFriend.fullName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.phone,color: Colors.green,),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<Message>>(
                  future: messageProvider.futureMessage,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Có lỗi xảy ra: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      List<Message> messages = snapshot.data!;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        // _scrollController.animateTo(
                        //   _scrollController.position.maxScrollExtent * 1.35,
                        //   duration: const Duration(milliseconds: 300),
                        //   curve: Curves.easeOut,
                        // );
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent * 1.35);
                      });

                      return Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            Message message = messages[index];
                            bool isMyMessage = message.userSendMessage.userId == you.userId &&
                                message.userReceiveMessage.userId == yourFriend.userId;
                            bool isFriendMessage = message.userSendMessage.userId == yourFriend.userId &&
                                message.userReceiveMessage.userId == you.userId;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  if (isMyMessage)
                                    checkUrl(message.content) ?
                                    Image.network(message.content,height: 100,fit: BoxFit.contain,)
                                    : Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.orangeAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        message.content,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  if (isFriendMessage)
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          child: ClipOval(
                                            child: Image.network(
                                              '${yourFriend.image}',
                                              fit: BoxFit.contain,
                                              width: 36,
                                              height: 36,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        checkUrl(message.content) ?
                                        Image.network(message.content,height: 100,fit: BoxFit.contain,)
                                            :
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            message.content,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
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
                if (messageProvider.showEmojiPicker)
                  EmojiPicker(
                    textEditingController: _messageController,
                    onEmojiSelected: (category, emoji) {
                      messageProvider.openEmoji(_messageController, emoji);
                    },
                    onBackspacePressed: () {
                      messageProvider.handleBackspace(_messageController);
                    },
                    config: const Config(
                      height: 256,
                      checkPlatformCompatibility: true,
                      viewOrderConfig: ViewOrderConfig(
                        top: EmojiPickerItem.categoryBar,
                        middle: EmojiPickerItem.emojiView,
                        bottom: EmojiPickerItem.searchBar,
                      ),
                      categoryViewConfig: CategoryViewConfig(),
                      bottomActionBarConfig: BottomActionBarConfig(),
                      searchViewConfig: SearchViewConfig(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions, color: Colors.white),
                        onPressed: () {
                          messageProvider.toggleEmojiPicker();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () {
                          _showImageOptions(context);
                        },
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            messageProvider.image != null ? // Hiển thị ảnh đã chọn
                              Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Image.file(
                                      messageProvider.image!,
                                      height: 100,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    right: -14,
                                    top: -14,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 26,
                                      ),
                                      onPressed: () {
                                        messageProvider.clearImage(); // Gọi hàm xóa ảnh
                                      },
                                    ),
                                  ),
                                ],
                              ) :
                            TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Nhập tin nhắn...',
                              ),
                              style: const TextStyle(color: Colors.white),
                              onChanged: (text) {
                                _messageController.value = _messageController.value.copyWith(
                                  text: messageProvider.emojify(text),
                                  selection: TextSelection.collapsed(offset: text.length),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () {
                            // Gửi tin nhắn, bao gồm cả ảnh nếu có
                            messageProvider.sendMessage(you, yourFriend, _messageController.text.trim());
                            _messageController.clear();
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
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
                messageProvider._pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn ảnh từ thư viện'),
              onTap: () {
                messageProvider._pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


}
