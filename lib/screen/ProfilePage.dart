import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_network_project/screen/HomePage.dart';
import 'dart:io';

import '../ApiService/ApiService.dart';
import '../DTO/UpdateUserDTO.dart';
import '../models/DefaultAvatar.dart';
import '../models/Theme.dart';
import '../models/User.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  File? _profileImage;
  File? _backgroundImage;

  final ImagePicker _picker = ImagePicker();

  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  User? get user => _user;
  File? get profileImage => _profileImage;
  File? get backgroundImage => _backgroundImage;
  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneController => _phoneController;

  UserProvider() {
    _resetUserData();
  }


  void setUser(User user) {
    _user = user;
    _resetUserData(); // Đồng bộ dữ liệu khi gán user mới
    notifyListeners();
  }

  ApiService apiService = ApiService();

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    await prefs.remove('username');
    _user = null;
    _profileImage = null;
    _backgroundImage = null;
    apiService.logout(username!);
    _resetUserData();
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    _user = updatedUser;
    _resetUserData();
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source, bool isProfile) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        if (isProfile) {
          _profileImage = File(image.path);
        } else {
          _backgroundImage = File(image.path);
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> updateUserInfo(UpdateUserDTO userDTO) async {
    ApiService apiService = ApiService();
    try {
      User updatedUser = await apiService.updateUser(userDTO, _profileImage, _backgroundImage);
      _user = updatedUser;
      _resetUserData();
      notifyListeners();
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  void _resetUserData() {
    _fullNameController.text = _user?.fullName ?? '';
    _emailController.text = _user?.email ?? '';
    _phoneController.text = _user?.phoneNumber ?? '';
    notifyListeners();
  }

  void updateFullName(TextEditingController controller) {
    _fullNameController.text = controller.text.trim();
    print( controller.text.trim());
    notifyListeners();
  }

  void updateEmail(TextEditingController controller) {
    _emailController.text = controller.text.trim();
    notifyListeners();
  }

  void updatePhone(TextEditingController controller) {
    _phoneController.text = controller.text.trim();
    notifyListeners();
  }

}

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    Widget _buildSection({required String title, required List<Widget> children}) {
      return Card(
        color: Colors.black87,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Floating Action Button for Refresh at the top-right corner
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    iconSize: 28,
                    icon: Icon(Icons.refresh,color: themeProvider.textColor,),
                    onPressed: userProvider._resetUserData
                  ),
                ],
              ),
              Text(
                title,
                style: TextStyle(
                  color: themeProvider.textProfile,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ...children,
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: themeProvider.theme,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: userProvider.backgroundImage != null
                    ? FileImage(userProvider.backgroundImage!) as ImageProvider
                    : NetworkImage(userProvider.user?.backgroundImage ?? Images.defaultBackground),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Profile Content
          SingleChildScrollView(
            child: Column(
              children: [
                // Profile Avatar
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => _showProfileImageOptions(context),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: userProvider.profileImage != null
                          ? FileImage(userProvider.profileImage!)
                          : NetworkImage(userProvider.user?.image ?? Images.defaultImage),
                      backgroundColor: themeProvider.textColor,
                    ),
                  ),
                ),
                // User Details
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: _buildSection(
                    title: "Thông tin cá nhân",
                    children: [
                      _buildDetailRow(context, "", userProvider.fullNameController.text, userProvider.fullNameController, "fullName"),
                      _buildDetailRow(context, "Username", userProvider.user?.username ?? '', null, ""),
                      _buildDetailRow(context, "Email", userProvider.emailController.text, userProvider.emailController, "email"),
                      _buildDetailRow(context, "Số điện thoại", userProvider.phoneController.text, userProvider.phoneController, "phone"),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.orangeAccent, // No solid color, just the gradient shadow
                                offset: Offset(0, 4), // Vertical shadow offset
                                blurRadius: 10, // The spread of the shadow
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const[
                                BoxShadow(
                                  color: Colors.transparent, // No solid shadow color here
                                  offset: Offset(0, 0), // No direct offset here for the shadow
                                  blurRadius: 0, // We will create shadow using the gradient
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Gradient shadow container
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 4,
                                  top: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft, // Gradient start
                                        end: Alignment.centerRight, // Gradient end
                                        colors: [themeProvider.textColor, Colors.black], // Gradient from white to black
                                      ),
                                    ),
                                  ),
                                ),
                                // Elevated button
                                ElevatedButton(
                                  onPressed: () => _onUpdatePressed(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent, // Button background color
                                    padding: const EdgeInsets.all(8.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0, // No default shadow for the button
                                  ),
                                  child: Text(
                                    'Update Profile',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeProvider.textColor),
                                  ),
                                ),
                              ],
                            ),
                          )
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onUpdatePressed(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print(userProvider.fullNameController.text);
    UpdateUserDTO userDTO = UpdateUserDTO(
      userId: userProvider.user!.userId!,
      fullName: userProvider.fullNameController.text,
      email: userProvider.emailController.text,
      phoneNumber: userProvider.phoneController.text,
    );
    userProvider.updateUserInfo(userDTO);
  }

  void _showProfileImageOptions(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.pop(context);
                userProvider.pickImage(ImageSource.camera, true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn ảnh trên máy'),
              onTap: () {
                Navigator.pop(context);
                userProvider.pickImage(ImageSource.gallery, true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Thay đổi ảnh nền'),
              onTap: () {
                Navigator.pop(context);
                _showBackgroundImageOptions(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showBackgroundImageOptions(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Background Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh nền mới'),
                onTap: () {
                  Navigator.pop(context);
                  userProvider.pickImage(ImageSource.camera, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn ảnh nền từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  userProvider.pickImage(ImageSource.gallery, false);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildDetailRow(BuildContext context, String label, String value, TextEditingController? controller, String field) {

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeProvider.textProfile,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: label.isEmpty
                ? Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  color: themeProvider.textProfile,
                ),
              ),
            )
                : Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.textProfile,
              ),
            ),
          ),
          if (controller != null)
            IconButton(
              icon: Icon(Icons.edit, color: themeProvider.textProfile),
              onPressed: () {
                _showEditDialog(context, controller, field);
              },
            ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, TextEditingController controller, String field) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter new value'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (field == "fullName") {
                  userProvider.updateFullName(controller);
                } else if (field == "email") {
                  userProvider.updateEmail(controller);
                } else if (field == "phone") {
                  userProvider.updatePhone(controller);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
