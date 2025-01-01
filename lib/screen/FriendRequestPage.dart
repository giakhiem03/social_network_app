import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_network_project/models/Theme.dart';

import '../ApiService/ApiService.dart';
import '../models/Friends.dart';
import '../models/User.dart';
import 'ProfilePage.dart';

class FriendRequestPage extends StatefulWidget {

  const FriendRequestPage({super.key});

  @override
  State<FriendRequestPage> createState() => _FriendRequestPage();

}

class _FriendRequestPage extends State<FriendRequestPage> {
  ApiService apiService = ApiService();

  late Future<List<Friends>> futureFriends;

  Future<List<Friends>> getAllFriends() {
    return apiService.getAllFriends();
  }


  void acceptFriends(int friendId) {
    setState(() {
      apiService.acceptFriend(friendId);
    });
  }

  @override
  void initState() {
    super.initState();
    futureFriends = getAllFriends();
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
              SizedBox(height: 60),
              Text(
                'Lời mời kết bạn',
                style: TextStyle(color: themeProvider.textColor, fontSize: 26),
              ),
            ],
          ),
          // ListView.builder
          Expanded(
            child: FutureBuilder<List<Friends>>(
              future: futureFriends,
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
                      Friends friend = snapshot.data![index];
                      return (friend.userIdReceive.userId == user!.userId &&
                          friend.statusRelationship == 1) ?
                        Container(
                        padding: const EdgeInsets.only(top: 10,bottom: 10),
                        margin: const EdgeInsets.only(bottom: 10),
                        color: Colors.blueGrey,
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 18),
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(friend.userIdSend.image!), // Thêm avatar động từ dữ liệu
                            ),
                            const SizedBox(width: 8),
                            Text( '${friend.userIdSend.fullName} đã gửi cho bạn lời mời kết bạn',
                              style:  TextStyle(color: themeProvider.textColor),
                            ),
                            IconButton(onPressed: ()=>acceptFriends(friend.id!), icon:const Icon(Icons.check, color: Colors.green,))
                          ],
                        ) ,
                      ): const Center();
                    },
                  );
                } else {
                  return Center(child: Text('Không có lời mời kết bạn nào',style: TextStyle(color: themeProvider.textColor),));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}