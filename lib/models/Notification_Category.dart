class Notification_Category {
   int? id;
   String name;

   Notification_Category({this.id,required this.name});

   factory Notification_Category.fromJson(Map<String, dynamic> json) {
      return Notification_Category(
          id: json["id"],
          name: json["name"],
      );
   }

   Map<String, dynamic> toJson() => {
      "id": id,
      "name": name,
   };
}