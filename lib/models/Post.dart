import 'package:social_network_project/models/User.dart';

class Post {
  int? postId;
  User? user; // Assuming User is another class in your app
  String? postImage;
  String? caption;
  String? detail;
  int? reactionQuantity;
  DateTime? postedTime;

  Post({
    this.postId,
    this.user,
    this.postImage,
    this.caption,
    this.detail,
    this.reactionQuantity,
    this.postedTime,
  });

  // Factory method to create a Post instance from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null, // Assuming User has a fromJson method
      postImage: json['postImage'],
      caption: json['caption'],
      detail: json['detail'],
      reactionQuantity: json['reactionQuantity'],
      postedTime: json['postedTime'] != null
          ? DateTime.parse(json['postedTime'])
          : null,
    );
  }

  // Method to convert a Post instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'user': user?.toJson(), // Assuming User has a toJson method
      'postImage': postImage,
      'caption': caption,
      'detail': detail,
      'reactionQuantity': reactionQuantity,
      'postedTime': postedTime?.toIso8601String(),
    };
  }
}
