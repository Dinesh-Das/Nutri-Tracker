import 'package:shared_preferences/shared_preferences.dart';

class UserLocalData {
  static String gname = "google_name";
  static String gmail = "google_email";
  static String gimg = "google_gimg";
  static String? glogkey = "google_login";
  static String name = "name";
  static String mail = "email";
  static String img = "photo";
  static String? logkey = "login";
  static String pass = "password";
  static String theme = 'theme';

  //Google Login Data saving

  static Future<bool?> saveGName(String? username) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(gname, username!);
  }

  static Future<bool?> saveGMail(String? useremail) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(gmail, useremail!);
  }

  static Future<bool?> saveGImg(String? imgUrl) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(gimg, imgUrl!);
  }

  static Future<String?> getGName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(gname);
  }

  static Future<String?> getGEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(gmail);
  }

  static Future<String?> getGImg() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(gimg);
  }

  static Future<bool> saveGLoginData(bool isUserLoggedIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(glogkey!, isUserLoggedIn);
  }

  static Future getGLogData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getBool(glogkey!);
  }

  // Normal Login Data Saving

  static Future<bool?> saveName(String username) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(name, username);
  }

  static Future<bool?> saveMail(String useremail) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(mail, useremail);
  }

  static Future<bool?> savePass(String password) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(pass, password);
  }

  static Future<bool?> saveImg(String imgUrl) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(img, imgUrl);
  }

  static Future<String?> getName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(name);
  }

  static Future<String?> getEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(mail);
  }

  static Future<String?> getPass() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(pass);
  }

  static Future<String?> getImg() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(img);
  }

  static Future<bool> saveLoginData(bool isUserLoggedIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(logkey!, isUserLoggedIn);
  }

  static Future getLogData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getBool(logkey!);
  }

  //Theme Data
  static Future<bool?> saveTheme(String themeData) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(theme, themeData);
  }

  static Future<String?> getTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(theme);
  }
}
//init me name = UserLocalData.getUserName() ?? '';