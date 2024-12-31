import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ApiService/ApiService.dart';
import '../models/Message.dart';
import '../models/User.dart';

class MessageProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  List<Message> _messages = [];
  List<Message> get messages => _messages;

  Future<void> initialize() async {
    _messages = await apiService.getAllMessage();
    notifyListeners();
  }

  Future<void> sendMessage(User you, User yourFriend, String content) async {
    if (content.isNotEmpty) {
      Message message = Message(
          userSendMessage: you, userReceiveMessage: yourFriend, content: content);
      await apiService.sendMessage(message);
      _messages.add(message); // Thêm tin nhắn mới vào danh sách
      notifyListeners();
    }
  }
}

class MessagePage extends StatefulWidget {
  final User you;
  final User yourFriend;

  MessagePage({required this.you, required this.yourFriend, Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool isAnimate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (isAnimate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white10,
        appBar: AppBar(
          backgroundColor: Colors.white10,
          elevation: 0,
          leading: const BackButton(color: Colors.white70),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.yourFriend.image!),
                onBackgroundImageError: (exception, stackTrace) {
                  // Xử lý lỗi load ảnh ở đây
                },
              ),
              const SizedBox(width: 8),
              Text(
                widget.yourFriend.fullName!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.phone, color: Colors.white70),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<MessageProvider>(
                builder: (context, messageProvider, child) {
                  final messages = messageProvider.messages;
                  _scrollToBottom(isAnimate: false);
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: messages.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMyMessage =
                          message.userSendMessage.userId == widget.you.userId &&
                              message.userReceiveMessage.userId ==
                                  widget.yourFriend.userId;
                      return Align(
                        alignment: isMyMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: isMyMessage
                            ? _buildMyMessage(message)
                            : _buildFriendMessage(message),
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputField(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMyMessage(Message message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message.content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildFriendMessage(Message message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(widget.yourFriend.image!),
          onBackgroundImageError: (exception, stackTrace) {
            // Xử lý lỗi load ảnh ở đây
          },
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Nhập tin nhắn...',
                hintStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white24,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () async {
                final content = _messageController.text.trim();
                if (content.isNotEmpty) {
                  await messageProvider.sendMessage(
                      widget.you, widget.yourFriend, content);
                  _messageController.clear();
                  _scrollToBottom(); // Cuộn xuống dưới cùng sau khi gửi tin nhắn
                }
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(12),
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
    );
  }
}