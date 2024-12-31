import 'package:flutter/material.dart';
import 'package:social_network_project/ApiService/ApiService.dart';
import 'package:social_network_project/models/Notifications.dart';

import '../models/User.dart';

class NotificationPage extends StatefulWidget {
  final User user;

  NotificationPage({required this.user, Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title: const Text(
          'Thông Báo',
          style: TextStyle(color: Colors.white70, fontSize: 26),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Notifications>>(
        future: _apiService.getAllNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                  'Lỗi: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white70),
                ));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final notifications = snapshot.data!
                .where((note) =>
            note.userIdReceive.username == widget.user.username)
                .toList();

            if (notifications.isEmpty) {
              return const Center(
                child: Text(
                  'Không có thông báo nào',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    color: Colors.blueGrey,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                        NetworkImage(notification.userIdSend.image!),
                      ),
                      title: Text(
                        notification.userIdSend.fullName!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      subtitle: Text(
                        notification.notificationCategory.id == 1
                            ? '${notification.userIdSend.fullName} đã like bài viết của bạn'
                            : '${notification.userIdSend.fullName} đã bình luận bài viết của bạn',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
                child: Text('Không có thông báo nào',
                    style: TextStyle(color: Colors.white70)));
          }
        },
      ),
    );
  }
}