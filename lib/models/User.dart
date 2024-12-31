import 'package:social_network_project/models/Post.dart';
import 'Role.dart';



class User {
  final int? userId;
  String? fullName;
  String username;
  final String password;
  String email;
  String? phoneNumber;
  final Role role;
  late bool status;
  final String? image;
  final String? backgroundImage;
  final Set<Post> posts;

  User({
    this.userId,
    this.fullName,
    required this.username,
    this.phoneNumber,
    required this.email,
    required this.password,
    required this.role,
    required this.status,
    this.image,
    this.backgroundImage,
    this.posts = const {},
  });


  factory User.fromJson(Map<String, dynamic> json) {
    // Chuyển 'posts' từ List<dynamic> thành Set<Post>
    List<dynamic> postsFromJson = json['posts'] as List<dynamic>? ?? [];
    Set<Post> posts = postsFromJson
        .map((postJson) => Post.fromJson(postJson as Map<String, dynamic>))
        .toSet();

    return User(
      userId: json["userId"],
      fullName: json["fullName"],
      username: json["username"],
      password: json["password"],
      email: json["email"],
      phoneNumber: json["phoneNumber"],
      image: json["image"],
      backgroundImage: json["backgroundImage"],
      role: Role.fromJson(json["role"]),
      status: json["status"],
      posts: posts,
    );
  }

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "fullName": fullName,
    "username": username,
    "password": password,
    "email": email,
    "phoneNumber": phoneNumber,
    "image": image,
    "backgroundImage": backgroundImage,
    "role": role.roleId,
    "status": status,
    "posts": posts.map((post) => post.postId).toList()
  };
}