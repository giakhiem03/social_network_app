import 'Notification_Category.dart';
import 'User.dart';

class Notifications {
   int? id;
   User userIdSend;
   User userIdReceive;
   Notification_Category notificationCategory;
   
   Notifications({this.id,required this.userIdSend,required this.userIdReceive,required this.notificationCategory});
   
   factory Notifications.fromJson(Map<String, dynamic> json) {
     return Notifications(
         id: json["id"],
         userIdSend: User.fromJson(json["userIdSend"]),
         userIdReceive : User.fromJson(json["userIdReceive"]),
         notificationCategory: Notification_Category.fromJson(json["notificationCategory"])
     );
   }

   Map<String, dynamic> toJson() => {
     "id": id,
     "userIdSend": userIdSend.userId,
     "userIdReceive": userIdReceive.userId,
     "notificationCategory": notificationCategory.id,
   };
   
}