
class UpdateUserDTO {
    int userId;
    String fullName;
    String email;
    String phoneNumber;

   UpdateUserDTO({required this.userId, required this.fullName,required this.email,required this.phoneNumber});

   factory UpdateUserDTO.fromJson(Map<String, dynamic> json) {
     return UpdateUserDTO(
       userId: json["userId"],
       fullName: json["fullName"],
       email: json["email"],
       phoneNumber: json["phoneNumber"],
     );
   }


   Map<String, dynamic> toJson() => {
     "userId" : userId,
     "fullName": fullName,
     "email": email,
     "phoneNumber": phoneNumber,
   };
}