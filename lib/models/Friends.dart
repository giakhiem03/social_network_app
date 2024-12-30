
import 'User.dart';

class Friends {
  int? id;
  late  User userIdSend;
  late  User userIdReceive;
  late  int statusRelationship;

  Friends({this.id,required this.userIdSend,required this.userIdReceive,required this.statusRelationship});

  // Factory method to create a Post instance from JSON
  factory Friends.fromJson(Map<String, dynamic> json) {
    return Friends(
      id: json['id'],
      userIdSend: User.fromJson(json['userIdSend']),
      userIdReceive: User.fromJson(json['userIdReceive']),
      statusRelationship: json['statusRelationship'],
    );
  }

  // Method to convert a Post instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userIdSend': userIdSend.userId,
      'userIdReceive': userIdReceive.userId,
      'statusRelationship': statusRelationship,
    };
  }

}