import 'package:social_network_project/models/User.dart';

class Post {
  final int? postId;
  final User userUpLoad;
  late final String? postImage;
  final String? caption;
  int? reactionQuantity;
  final String postedTime;
  final Set<User> users;

  Post({
    this.postId,
    required this.userUpLoad,
    this.postImage,
    this.caption,
    this.reactionQuantity,
    required this.postedTime,
    this.users = const {},
  });

  // Factory method to create a Post instance from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    List<dynamic> likedUsersFromJson = json['users']  as List<dynamic>? ?? []; // Đảm bảo json['users'] là List<dynamic> có thể null

    Set<User> likedUsers = likedUsersFromJson
        .map((userJson) => User.fromJson(userJson as Map<String, dynamic>)) // Casting để đảm bảo userJson là Map<String, dynamic>
        .toSet(); // Chuyển đổi thành List<User>

    return Post(
      postId: json['postId'],
      userUpLoad: User.fromJson(json['userUpLoad']),
      postImage: json['postImage'],
      caption: json['caption'],
      reactionQuantity: json['reactionQuantity'],
      postedTime: json['postedTime'],
      users: likedUsers,
    );
  }

  // Method to convert a Post instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userUpLoad': userUpLoad.toJson(),
      'postImage': postImage,
      'caption': caption,
      'reactionQuantity': reactionQuantity,
      'postedTime': postedTime,
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}
