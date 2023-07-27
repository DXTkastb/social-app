import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

import '../shared-prefs/shared_pref_service.dart';

class RestClient {
  static final Uri loginUrl = Uri.parse("http://192.168.29.136:8080/login");
  static final Uri signupUrl = Uri.parse("http://192.168.29.136:8080/signup");
  static final Uri updateDetailsUrl =
      Uri.parse("http://192.168.29.136:8080/updateUserDetails");
  static final Uri updateUserPassword = Uri.parse("http://192.168.29.136:8080/updatePassword");
  static final Uri auth = Uri.parse("http://192.168.29.136:8080/auth");
  static final Uri updateProfileImage = Uri.parse("http://192.168.29.136:8080/updateProfileImage");
  static late Client rest;

  static init() {
    rest = Client();
  }

  static retryNewConnection() {
    closeClient();
    rest = Client();
  }

  static closeClient() {
    rest.close();
  }

  static Future<Map<String, dynamic>> login(
      String accountName, String password) async {
    final fcmTokenKey = await FirebaseMessaging.instance.getToken();
    Map<String, dynamic> map = {};
    try {
      var response = await rest.post(loginUrl, body: {
        "accountname": accountName,
        "password": password,
        'fkey': fcmTokenKey
      });
      var statusCode = response.statusCode;

      if (statusCode == 500 || statusCode == 401) {
        map['estatus'] = response.headers['error'];
      }
      if (statusCode == 200) {
        map['user_data'] = jsonDecode(response.body) as Map;
        map['auth-header'] = response.headers['auth-token'];
      }
      return map;
    } catch (e) {
      map['estatus'] = 'Server Not Reachable';
      RestClient.retryNewConnection();
      return map;
    }
  }

  static Future<Map<String, dynamic>> signup(String accountName,
      String password, String username, String? imagePath) async {
    Map<String, dynamic> map = {};
    final fmInstance = FirebaseMessaging.instance;
    try {
      final token = await fmInstance.getToken();
      MultipartRequest multipartRequest = MultipartRequest('POST', signupUrl);
      multipartRequest.fields.addAll({
        "accountname": accountName,
        "password": password,
        "username": username,
        "fkey": token!,
        "imageAvailable": "false"
      });
      if (imagePath != null) {
        multipartRequest.files
            .add(await MultipartFile.fromPath('image', imagePath));
        multipartRequest.fields.addAll({"imageAvailable": "true"});
      }
      var streamedResponse = await rest.send(multipartRequest);
      var response = await Response.fromStream(streamedResponse);
      int statusCode = response.statusCode;
      if (statusCode == 500 || statusCode == 409) {
        map['estatus'] = response.headers['error'];
        return map;
      } else if (statusCode == 200) {
        map['user_data'] = jsonDecode(response.body) as Map;
        map['auth-header'] = response.headers['auth-token'];
      }
      return map;
    } catch (e) {
      map['estatus'] = 'Server Not Reachable';
      RestClient.retryNewConnection();
      return map;
    }
  }

  static Future<Map<String, dynamic>> authUser(String token) async {
    Map<String, dynamic> map = {};
    try {
      var response = await rest.post(auth,
          headers: {"auth-token": token}).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        map['user_data'] = jsonDecode(response.body) as Map;
      } else if (response.statusCode == 401) {
        map['estatus'] = 2;
      }
      return map;
    } catch (e) {
      map['estatus'] = 3;
      RestClient.retryNewConnection();
      return map;
    }
  }

  static Future<Map<String, dynamic>> addExtraUserDetails(String accountName,
      String delegation, String link, String about, String username) async {
    Map<String, dynamic> map = {};
    String? token =
        (SharedPrefService.sharedPreferences).get("auth-token") as String?;
    try {
      Map<String, String> postData = {
        "accountname": accountName,
        "delegation": delegation,
        "link": link,
        "username": username,
        "about": about,
      };

      var jsonData = jsonEncode(postData);
      var response =
          await rest.post(updateDetailsUrl, body: jsonData, headers: {
        "auth-token": token ?? "",
        'Content-Type': 'application/json; charset=UTF-8',
      });

      int statusCode = response.statusCode;
      if (statusCode == 500 || statusCode == 403) {
        map['estatus'] = response.headers['error'];
        return map;
      } else if (statusCode == 200) {
        map['user_data'] = jsonDecode(response.body) as Map;
      }
      return map;
    } catch (e) {
      map['estatus'] = 'Server Not Reachable';
      RestClient.retryNewConnection();
      return map;
    }
  }

  static Future<Map<String, dynamic>> updateUserDetails({
    required String accountName,
    required String username,
    required String delegation,
    required String link,
    required String about,
  }) async {
    Map<String, dynamic> map = {};
    String? token =
        (SharedPrefService.sharedPreferences).get("auth-token") as String?;
    Map<String, String> postData = {
      "accountname": accountName,
      "delegation": delegation,
      "username": username,
      "link": link,
      "about": about,
    };
    var jsonData = jsonEncode(postData);
    try {
      var response =
          await rest.post(updateDetailsUrl, body: jsonData, headers: {
        "auth-token": token ?? "",
        'Content-Type': 'application/json; charset=UTF-8',
      });
      int statusCode = response.statusCode;
      if (statusCode == 500 || statusCode == 403) {
        map['estatus'] = response.headers['error'];
        return map;
      } else if (statusCode == 200) {
        map['user_data'] = jsonDecode(response.body) as Map;
      }
    }
    catch (_){}
    return map;
  }

  static Future<int> changePassword(String password,String accountName) async {
    var jsonData = jsonEncode({
      'accountname' : accountName,
      'password' : password
    });
    String? token =
    (SharedPrefService.sharedPreferences).get("auth-token") as String?;
    try {
      var response = await rest.post(updateUserPassword, body : jsonData,headers: {
        "auth-token": token ?? "",
        'Content-Type': 'application/json; charset=UTF-8',
      });
      var resbody = int.parse(response.body as String);
      return resbody;
    }
    catch (e) {
      return 500;
    }
  }
  static Future<String> changeDp(String accountname, String path) async {
    try {
      var req = MultipartRequest('POST', updateProfileImage);
      req.fields.addAll({
        'accountname': accountname,
      });
      String? token =
          (SharedPrefService.sharedPreferences).get("auth-token") as String?;
      req.headers.addAll({
        "auth-token": token ?? "",
      });
      req.files.add(await MultipartFile.fromPath(
          'image', path,
          contentType: MediaType.parse('image/jpeg')));
      var client = Client();
      var res = await client.send(req);
      var response = await Response.fromStream(res);
      return (response.body);
    }
    catch (e) {
      return "";
    }
  }
}
