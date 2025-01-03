import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ApiService/ApiService.dart';
import '../models/Friends.dart';
import '../models/Theme.dart';
import '../models/User.dart';
import 'MessagePage.dart';
import 'ProfilePage.dart';

class ListMessagePage extends StatefulWidget {

  const ListMessagePage({super.key});

  @override
  State<ListMessagePage> createState() => _ListMessagePage();

}

class _ListMessagePage extends State<ListMessagePage> {
  ApiService apiService = ApiService();

  late Future<List<Friends>> futureFriends;

  Future<List<Friends>> getAllFriends() {
    return apiService.getAllFriends();
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
              const SizedBox(height: 60),
              Text(
                'Tin nhắn',
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
                      if((friend.userIdSend.userId == user!.userId &&
                          friend.statusRelationship == 2)){
                        return ElevatedButton(
                          onPressed: () {
                            // Handle button press action here
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context)=>
                                    MessagePage(you: user,yourFriend: friend.userIdReceive,)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.textColor,
                            padding: EdgeInsets.zero, // Remove default padding to control it in the Container
                            elevation: 5, // Add some shadow to elevate the button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded corners for a smooth look
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Adjust padding for better spacing
                            margin: const EdgeInsets.only(top: 2,bottom:2), // Bottom margin to separate items
                            child: Row(
                              children: [
                                const SizedBox(width: 16), // Reduced width for tighter spacing
                                CircleAvatar(
                                  radius: 18, // Slightly larger radius for prominence
                                  backgroundImage: NetworkImage(friend.userIdReceive.image!), // Dynamic avatar
                                ),
                                const SizedBox(width: 16), // Space between avatar and text
                                Expanded( // Use Expanded to make text take remaining space
                                  child: Text(
                                    utf8.decode(friend.userIdReceive.fullName!.runes.toList()), // Display friend's full name
                                    style: TextStyle(
                                      color: themeProvider.textFullName, // Light text color for contrast
                                      fontSize: 16, // Adjust font size for better readability
                                      fontWeight: FontWeight.w500, // Make the text bold for better clarity
                                    ),
                                    overflow: TextOverflow.ellipsis, // Handle overflow for longer names
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if((friend.userIdReceive.userId == user.userId &&
                          friend.statusRelationship == 2)){
                        return ElevatedButton(
                          onPressed: () {
                            // Handle button press action here
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context)=>
                                    MessagePage(you: user,yourFriend: friend.userIdSend,)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.textColor,
                            padding: EdgeInsets.zero, // Remove default padding to control it in the Container
                            elevation: 5, // Add some shadow to elevate the button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded corners for a smooth look
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Adjust padding for better spacing
                            margin: const EdgeInsets.only(top: 2,bottom:2), // Bottom margin to separate items
                            child: Row(
                              children: [
                                const SizedBox(width: 16), // Reduced width for tighter spacing
                                CircleAvatar(
                                  radius: 18, // Slightly larger radius for prominence
                                  backgroundImage: NetworkImage(friend.userIdReceive.image!), // Dynamic avatar
                                ),
                                const SizedBox(width: 16), // Space between avatar and text
                                Expanded( // Use Expanded to make text take remaining space
                                  child: Text(
                                    utf8.decode(friend.userIdSend.fullName!.runes.toList()), // Display friend's full name
                                    style: TextStyle(
                                      color: themeProvider.textFullName, // Light text color for contrast
                                      fontSize: 16, // Adjust font size for better readability
                                      fontWeight: FontWeight.w500, // Make the text bold for better clarity
                                    ),
                                    overflow: TextOverflow.ellipsis, // Handle overflow for longer names
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
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