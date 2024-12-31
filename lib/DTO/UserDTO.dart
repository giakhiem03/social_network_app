class UserDTO {

  UserDTO({ required this.username,required this.password});

  final String? username;
  final String? password;

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO( username: json["username"],password: json["password"]);
  }


  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
  };

}