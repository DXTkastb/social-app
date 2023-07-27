import '/data/user_details.dart';
import '/rest-service/rest_client.dart';
import '/shared-prefs/shared_pref_service.dart';

class AppState {
  /*
   0 : NONE
   1 : LOGGEDIN
   2 : LOGGEDOUT
   3 : SERVER_ERROR : Unable to verify token with server, NOT internet connection error
  */

  int state = 0;
  User user = User.getNullUser();

  void stateSetter(int s) {
    state = s;
  }

  void userSetter(User userdata) {
    user = userdata;
  }

  Future<AppState> getAppState() async {
    AppState appStateData = AppState();

    String? token =
        (SharedPrefService.sharedPreferences).get("auth-token") as String?;
    if (token == null) {
      appStateData.stateSetter(2);
      appStateData.userSetter(User.getNullUser());
    } else {
      var data = await RestClient.authUser(token);
      if (data.containsKey('estatus')) {
        appStateData.stateSetter(data['estatus']);
      } else if (data.containsKey('user_data')) {
        appStateData.stateSetter(1);
        appStateData.userSetter(User.newUser(data['user_data']));
      }
    }
    return appStateData;
  }

}
