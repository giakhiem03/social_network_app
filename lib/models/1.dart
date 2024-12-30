import 'Post.dart';
import 'User.dart';

class 1 {
  final int? id;
  final Post post;
  final User user;
  final String content;

  Comments({this.id,required this.post,required this.user,required this.content});

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
      id: json["id"],
      post: Post.fromJson(json["post"]),
      user: User.fromJson(json["user"]),
      content: json["content"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "post": post.postId,
    "user": user.userId,
    "content": content,
  };

}