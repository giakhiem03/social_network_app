import 'package:social_network_project/ApiService/ApiService.dart';

class Images {
  static String url = ApiService.getBaseUrl();
  static String defaultImage = '$url/images/DefaultAvatar.jpg';
  static String defaultBackground = '$url/images/bgProfile.jpg';
}