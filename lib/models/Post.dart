import 'package:social_network_project/models/User.dart';

class Post {
  int? postId;
  User user; // Assuming User is another class in your app
  String? postImage;
  String? caption;
  int? reactionQuantity;
  DateTime postedTime;

  Post({
    this.postId,
    required this.user,
    this.postImage,
    this.caption,
    this.reactionQuantity,
    required this.postedTime,
  });

  // Factory method to create a Post instance from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'],
      user:  User.fromJson(json['user']), // Assuming User has a fromJson method
      postImage: json['postImage'],
      caption: json['caption'],
      reactionQuantity: json['reactionQuantity'],
      postedTime: DateTime.parse(json['postedTime']),
    );
  }

  // Method to convert a Post instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'user': user.toJson(), // Assuming User has a toJson method
      'postImage': postImage,
      'caption': caption,
      'reactionQuantity': reactionQuantity,
      'postedTime': postedTime.toIso8601String(),
    };
  }
}
