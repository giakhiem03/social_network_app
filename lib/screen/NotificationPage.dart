import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_network_project/ApiService/ApiService.dart';
import 'package:social_network_project/models/Notifications.dart';

import '../models/Theme.dart';
import 'ProfilePage.dart';

class NotificationPage extends StatefulWidget {

  NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {
  late Future<List<Notifications>> futureNote;

  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureNote = apiService.getAllNotes();
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context); // Lấy dữ liệu người dùng từ Provider
    final user = userProvider.user;

    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.theme,
      body: Column(
        children: [
          // Tiêu đề
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Text(
                'Thông Báo',
                style: TextStyle(color: themeProvider.textColor, fontSize: 26),
              ),
            ],
          ),
          // ListView.builder
          Expanded(
            child: FutureBuilder<List<Notifications>>(
              future: futureNote,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}',style: TextStyle(color: themeProvider.textColor),));
                } else if (snapshot.hasData || snapshot.data!.isNotEmpty) {
                  // ListView.builder hiển thị các thông báo
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Notifications notification = snapshot.data![index];
                      return notification.userIdReceive.username == user!.username ?
                        Container(
                        padding: const EdgeInsets.only(top: 10,bottom: 10),
                        margin: const EdgeInsets.only(bottom: 10),
                        color: Colors.blueGrey,
                          child: Row(
                            children: [
                              const SizedBox(width: 18),
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(notification.userIdSend.image!), // Thêm avatar động từ dữ liệu
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    utf8.decode(notification.userIdSend.fullName!.runes.toList()), // Hiển thị tên người dùng
                                    style: TextStyle(color: themeProvider.textColor),
                                  ),
                                  notification.notificationCategory.id == 1 ?
                                  Text( '${utf8.decode(notification.userIdSend.fullName!.runes.toList())} đã like bài viết của bạn',
                                    style: TextStyle(color: themeProvider.textColor),
                                  ) :
                                  Text( '${utf8.decode(notification.userIdSend.fullName!.runes.toList())} đã bình luận bài viết của bạn',style: TextStyle(color: themeProvider.textColor),),
                                ],
                              ),
                            ],
                          ) ,
                      ) : Container();
                    },
                  );
                } else {
                  return Center(child: Text('Không có thông báo nào',style: TextStyle(color: themeProvider.textColor),));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
