import 'User.dart';

class Message {
  int? id;
  User userSendMessage;
  User userReceiveMessage;
  String content;

  Message({this.id, required this.userSendMessage, required this.userReceiveMessage, required this.content});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      userSendMessage: User.fromJson(json['userSendMessage']),
      userReceiveMessage: User.fromJson(json['userReceiveMessage']),
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userSendMessage': userSendMessage.toJson(), // Lưu toàn bộ thông tin user
      'userReceiveMessage': userReceiveMessage.toJson(), // Lưu toàn bộ thông tin user
      'content': content,
    };
  }
}