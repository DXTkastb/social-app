import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/communication_lib.dart';
import '../login-signup/extra_user_details.dart';
import '../rsocket-engine/risolate_service/communication_data/post.dart';
import '/screens/help_about.dart';
import '/screens/settings_screen.dart';
import '/screens/story_view.dart';
import '/screens/external_user_view.dart';
import '/screens/post_image_story_screen.dart';
import '/screens/post_view.dart';
import '/login-signup/login.dart';
import '/error_screens/network_error_screen.dart';
import '/login-signup/signup.dart';
import '/screens/user_main_ui.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutePaths.addExtraUserDetails:
        return MaterialPageRoute(builder: (_) =>  const ExtraUserDetailsPage());
      case AppRoutePaths.signupPageRoute:
        return MaterialPageRoute(builder: (_) =>  const SignupPage());
      case AppRoutePaths.aboutRoute:
        return MaterialPageRoute(builder: (_) =>  const About());
      case AppRoutePaths.settingRoute:
        return MaterialPageRoute(builder: (_) =>  const SettingScreen());
      case AppRoutePaths.mainUiPage:
        return MaterialPageRoute(builder: (_) => const InitializationUIView());
      case AppRoutePaths.loginPageRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutePaths.errorPageRoute:
        return MaterialPageRoute(builder: (_) => const NetworkErrorPage());
      case AppRoutePaths.externalUserViewRoute:
        User user = settings.arguments as User;
        return MaterialPageRoute(builder: (_) => ExternalUserView(user: user,));
      case AppRoutePaths.storyViewRoute:
        String accountName = (settings.arguments as List)[0] as String;
        List? list = (settings.arguments as List)[1];
        int? memId = (settings.arguments as List)[2];
        return MaterialPageRoute(builder: (_) => StoryViewScreen(accountname: accountName,currentUserStories: list,memoryId: memId,));
      case AppRoutePaths.uploadView:
        int type = settings.arguments! as int;
        return MaterialPageRoute(builder: (_) => UploadPostStoryScreen(type: type,));
      case AppRoutePaths.postViewRoute:
        int userPostId =  (settings.arguments! as List)[1];
        bool fromComment = (settings.arguments! as List)[0];
        return MaterialPageRoute(builder: (_) => PostViewScreen(fromComment: fromComment, postid: userPostId,));
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                  child: Text('404')),
            ));
    }
  }
}

class AppRoutePaths {

  static const String mainUiPage = 'main_page';
  static const String errorPageRoute = 'network_error';
  static const String loginPageRoute = 'login';
  static const String signupPageRoute = 'signup';
  static const String addExtraUserDetails = 'extrauserdetials';
  static const String settingRoute = 'settings';
  static const String aboutRoute = 'about';
  static const String storyViewRoute = 'story_view';
  static const String externalUserViewRoute = 'external_user';
  static const String postViewRoute = 'post_view';
  static const String uploadView = 'upload_view';

  static String? getInitialRoute(int state) {
    if(state == 1) return mainUiPage;
    else if(state == 2) return loginPageRoute;
    else if(state == 3) return errorPageRoute;
    return null;
  }

}