import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ApiService/ApiService.dart';
import '../models/Message.dart';
import '../models/User.dart';

class MessageProvider extends ChangeNotifier {
  ApiService apiService = ApiService();
  late Future<List<Message>> futureMessage;

  MessageProvider() {
    initialize();
  }

  void initialize() {
    futureMessage = apiService.getAllMessage();
  }

  void sendMessage(User you, User yourFriend, String content) {
    if(content.isNotEmpty) {
      Message message = Message(userSendMessage: you,
          userReceiveMessage: yourFriend, content: content);
      apiService.sendMessage(message).then((onValue){
        futureMessage = apiService.getAllMessage();
        notifyListeners();
      }).catchError((onError){
        print(onError);
      });
    }
  }

}

class MessagePage extends StatelessWidget {
  User you;
  User yourFriend;

  MessagePage({required this.you, required this.yourFriend, super.key});

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white10,
        body: Consumer<MessageProvider>(
            builder: (context, messageProvider, child) {
              // Gọi lại API mỗi khi cần
              messageProvider.initialize();
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white24, width: 2.0), // Border phía dưới
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
                    // Khoảng cách giữa ảnh và tên
                    Text(
                      '${yourFriend.fullName}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const Spacer(),
                    // Đẩy các thành phần còn lại sang bên phải
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.phone),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<Message>>(
                future: messageProvider.futureMessage,
                // Future lấy từ hàm getAllPosts
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(), // Hiển thị khi đang tải
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Có lỗi xảy ra: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    List<Message> messages = snapshot.data!;

                    // Sau khi tải xong, cuộn đến cuối danh sách
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });

                    // Nếu có dữ liệu, hiển thị danh sách tin nhắn
                    return Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          Message message = messages[index];
                          // Xác định xem tin nhắn là của bạn hay của bạn bè
                          bool isMyMessage =
                              message.userSendMessage.userId == you.userId &&
                                  message.userReceiveMessage.userId ==
                                      yourFriend.userId;
                          bool isFriendMessage = message
                                      .userSendMessage.userId ==
                                  yourFriend.userId &&
                              message.userReceiveMessage.userId == you.userId;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: isMyMessage
                                  ? CrossAxisAlignment
                                      .end // Tin nhắn của bạn căn phải
                                  : CrossAxisAlignment.start,
                              // Tin nhắn bạn bè căn trái
                              children: [
                                if (isMyMessage)
                                  Container(
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
                                          decoration: TextDecoration.none),
                                    ),
                                  ),
                                if (isFriendMessage)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        child: ClipOval(
                                          child: Image.network(
                                            '${yourFriend.image}',
                                            fit: BoxFit.contain,
                                            // Điều chỉnh fit
                                            width: 36,
                                            // Kích thước ảnh (phải khớp với radius)
                                            height: 36,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Khoảng cách giữa ảnh và nội dung
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          message.content,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Material(
                      color: Colors.transparent, // Không làm nền của Material thay đổi màu
                      shape: const CircleBorder(), // Tạo hình tròn cho vật liệu
                      child: InkWell(
                        onTap: () {
                          messageProvider.sendMessage(you,yourFriend,_messageController.text.trim());
                          _messageController.clear();
                          },
                        borderRadius: BorderRadius.circular(30), // Đảm bảo có border tròn khi nhấn
                        child: Container(
                          padding: const EdgeInsets.all(10), // Thêm padding để tạo không gian cho icon
                          decoration: const BoxDecoration(
                            color: Colors.blue, // Màu nền khi không nhấn
                            shape: BoxShape.circle, // Đảm bảo nút có hình tròn
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white, // Màu icon
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ],
          );
        }),
      ),
    );
  }


}
