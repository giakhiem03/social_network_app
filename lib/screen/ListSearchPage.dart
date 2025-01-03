import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:social_network_project/models/Friends.dart';
import 'package:social_network_project/models/User.dart';

import '../ApiService/ApiService.dart';
import '../models/Theme.dart';

class SearchProvider extends ChangeNotifier {
  ApiService apiService = ApiService();

  Future<List<User>> searchUsersByName(String name) {
    return apiService.searchByName(name);
  }

  Future<List<Friends>> getAllFriends() {
    return apiService.getAllFriends();
  }

  void addFriends(User userIdSend, User userIdReceive, int status, BuildContext context) {
    Friends friend = Friends(
      userIdSend: userIdSend,
      userIdReceive: userIdReceive,
      statusRelationship: status,
    );
    apiService.addFriend(friend).then((f){
      getAllFriends().then((friends) {
        // Tìm bài viết có ID tương ứng và cập nhật trạng thái like
        for (var friend in friends) {
          if (friend.id == f.id) {
            friend.userIdSend = f.userIdSend;
            friend.userIdReceive = f.userIdReceive;
            friend.statusRelationship = f.statusRelationship;
            break;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text(
                'Thêm bạn thành công', // Nội dung lỗi từ server
                style: TextStyle(color: Colors.white),
              ),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3), // Thời gian hiển thị
          ),
        );
        notifyListeners(); // Chỉ cập nhật trạng thái giao diện
      });
    }).catchError((onError){
      print('Có lỗi: $onError');
    });
  }

  void cancelAddFriends(int friendId,BuildContext context) {
    apiService.removeFriend(friendId).then((onValue){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text(
              'Hủy bạn thành công', // Nội dung lỗi từ server
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3), // Thời gian hiển thị
        ),
      );
      notifyListeners();
    }).catchError((onError){
      print(onError);
    }); // Thông báo cập nhật
  }

  void acceptFriends(int friendId,BuildContext context) {
    apiService.acceptFriend(friendId).then((onValue){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text(
              'Đồng ý kết bạn thành công', // Nội dung lỗi từ server
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3), // Thời gian hiển thị
        ),
      );
      notifyListeners(); // Thông báo cập nhật
    }).catchError((onError){
      print(onError);
    });
  }
}

class ListSearchPage extends StatelessWidget {
  final User userSend;
  final String name;

  ListSearchPage({required this.userSend, required this.name, super.key});

  Icon getIcon(User user, List<Friends> friends, User userSend) {
    for (Friends friend in friends) {
      if (friend.userIdSend.userId == userSend.userId &&
          friend.userIdReceive.userId == user.userId) {
        if (friend.statusRelationship == 1) {
          return Icon(Icons.cancel, color: Colors.red[300]); // Đang chờ xác nhận
        } else {
          return const Icon(FontAwesomeIcons.userGroup, color: Colors.green); // Đã là bạn bè
        }
      } else if (friend.userIdSend.userId == user.userId &&
          friend.userIdReceive.userId == userSend.userId) {
        if (friend.statusRelationship == 1) {
          return const Icon(Icons.check, color: Colors.blue); // Đang chờ chấp nhận
        } else {
          return const Icon(FontAwesomeIcons.userGroup, color: Colors.green); // Đã là bạn bè
        }
      }
    }
    return const Icon(Icons.add, color: Colors.white); // Có thể kết bạn
  }

  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: themeProvider.theme,
            body: Column(
              children: [
                // Tiêu đề
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const BackButton(),
                    const SizedBox(
                      height: 80,
                      width: 26,
                    ),
                    Text(
                      'Danh sách tìm kiếm',
                      style: TextStyle(color: themeProvider.textColor, fontSize: 26),
                    ),
                  ],
                ),
                // ListView.builder
                Expanded(
                  child: FutureBuilder(
                    future: Future.wait([
                      searchProvider.searchUsersByName(name),
                      searchProvider.getAllFriends()
                    ]),
                    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Không tìm thấy người dùng nào có tên là $name',
                            style: TextStyle(color: themeProvider.textColor),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        List<User> users = snapshot.data![0];
                        List<Friends> friends = snapshot.data![1];

                        if (users.isEmpty) {
                          return Center(
                            child: Text(
                              'Không tìm thấy người dùng nào có tên là $name',
                              style: TextStyle(color: themeProvider.textColor),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            User user = users[index];
                            Icon icon = getIcon(user, friends, userSend);
                            if(user.username == userSend.username) {
                              icon = const Icon(Icons.account_circle);
                            }
                            return Container(
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              margin: const EdgeInsets.only(bottom: 10),
                              color: Colors.blueGrey,
                              child: Row(
                                children: [
                                  const SizedBox(width: 30),
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(user.image!),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    user.fullName!,
                                    style: TextStyle(color: themeProvider.textColor),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      if (icon.icon == Icons.add) {
                                        searchProvider.addFriends(
                                            userSend, user, 1,context);

                                      } else if (icon.icon == Icons.cancel ||
                                          icon.icon == FontAwesomeIcons.userGroup) {
                                        Friends friend = friends.firstWhere(
                                              (f) =>
                                              (f.userIdSend.userId ==
                                                  userSend.userId &&
                                                  f.userIdReceive.userId ==
                                                      user.userId) ||
                                                  (f.userIdSend.userId ==
                                                  user.userId &&
                                                  f.userIdReceive.userId ==
                                                      userSend.userId),
                                        );
                                        searchProvider.cancelAddFriends(friend.id!,context);
                                      } else if(icon.icon == Icons.check) {
                                        Friends friend = friends.firstWhere(
                                              (f) =>
                                              (f.userIdSend.userId ==
                                                  userSend.userId &&
                                                  f.userIdReceive.userId ==
                                                      user.userId) ||
                                                  (f.userIdSend.userId ==
                                                  user.userId &&
                                                  f.userIdReceive.userId ==
                                                      userSend.userId)
                                        );
                                        searchProvider.acceptFriends(friend.id!,context);
                                      }
                                    },
                                    icon: icon,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Text(
                            'Không có dữ liệu',
                            style: TextStyle(color: themeProvider.textColor),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

