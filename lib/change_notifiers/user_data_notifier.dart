import 'package:flutter/material.dart';

import '../data/user_details.dart';
import '../rest-service/rest_client.dart';

class UserDataNotifier extends ChangeNotifier {
  late String username;
  late String? profileurl;
  late String? delegation;
  late String? about;
  late String? link;
  bool _disposed = false;

  UserDataNotifier(User u) {
    username = u.username;
    profileurl = u.profileurl;
    delegation = u.delegation;
    about = u.about;
    link = u.link;
  }

  Future<Map> refreshData(String accountName, int type, String value) async {
    /*
    type =>
    1 : username
    2 : profile url
    3 : link
    4 : about
     */
    Map map = {};

    if (type == 1)
      map = await RestClient.updateUserDetails(
          accountName: accountName,
          username: value,
          delegation: delegation ?? '',
          link: link ?? '',
          about: about ?? '');
    else if (type == 3)
      map = await RestClient.updateUserDetails(
          accountName: accountName,
          username: username,
          delegation: delegation ?? '',
          link: value ?? '',
          about: about ?? '');
    else if (type == 4)
      map = await RestClient.updateUserDetails(
          accountName: accountName,
          username: username,
          delegation: delegation ?? '',
          link: link ?? '',
          about: value ?? '');

    if (map.isNotEmpty) {
      map = map['user_data'] as Map;
      username = map['username'] ?? username;
      profileurl = map['profileurl'] ?? profileurl;
      delegation = map['delegation'] ?? delegation;
      about = map['about'] ?? about;
      link = map['link'] ?? link;
      Future((){
        if(!_disposed) notifyListeners();
      });

      //   print('THIS IS NEW MAP') ;
      //   print(map);
      //   Future(() async {
      //     if (_disposed) return;
      //     var port = ReceivePort();
      //     var output = port.first;
      //     MainIsolateEngine.engine.sendMessage({
      //       'operation': 'REFRESH_METADATA',
      //       'data': {
      //         'accountName': accountName,
      //       },
      //       'temp_port': port.sendPort
      //     });
      //     var list = (await output) as List;
      //     port.close();
      //     if (!_disposed) {
      //       if (list.isEmpty) {
      //       } else {
      //         var metadata = list[0] as User;
      //         username = metadata.username;
      //         profileurl = metadata.profileurl;
      //         delegation = metadata.delegation;
      //         about = metadata.about;
      //         link = metadata.link;
      //         notifyListeners();
      //       }
      //     }
      //   });
      // }
    }
    return map;
  }

  void appStateChangeNotify(User user) {
    username = user.username;
    profileurl = user.profileurl;
    delegation = user.delegation;
    about = user.about;
    link = user.link;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
  }
}
