
import 'User.dart';

class Message {
  int? id;
  User userSendMessage;
  User userReceiveMessage;
  String content;

  Message({this.id,required this.userSendMessage,required this.userReceiveMessage,required this.content});

  // Factory method to create a Post instance from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      userSendMessage: User.fromJson(json['userSendMessage']),
      userReceiveMessage:  User.fromJson(json['userReceiveMessage']),
      content: json['content'],
    );
  }

  // Method to convert a Post instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userSendMessage': userSendMessage.userId,
      'userReceiveMessage': userReceiveMessage.userId,
      'content': content,
    };
  }

}