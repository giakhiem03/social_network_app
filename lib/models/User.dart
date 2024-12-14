import 'Role.dart';

class User {
  User(
      {this.userId,
      this.fullName,
      required this.username,
      this.phoneNumber,
      required this.email,
      required this.password,
      required this.role,
      required this.status,
      this.image});

  final int? userId;
  final String? fullName;
  final String username;
  final String password;
  final String email;
  final String? phoneNumber;
  final Role role;
  late bool status;
  final String? image;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        userId: json["userId"],
        fullName: json["fullName"],
        username: json["username"],
        password: json["password"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        role: Role.fromJson(json["role"]),
        status: json["status"],
        image: json["image"]);
  }

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "fullName": fullName,
        "username": username,
        "password": password,
        "email": email,
        "phoneNumber": phoneNumber,
        "role": role.toJson(),
        "status": status,
        "image": image
      };
}
