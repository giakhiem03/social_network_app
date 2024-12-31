
class LoginDTO {

  final String? username;
  final String? password;

  LoginDTO({ required this.username,required this.password});

  factory LoginDTO.fromJson(Map<String, dynamic> json) {
    return LoginDTO( username: json["username"],password: json["password"]);
  }

  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
  };

}
