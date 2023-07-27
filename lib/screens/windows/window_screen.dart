import 'package:flutter/cupertino.dart';
import '/screens/windows/search_screen.dart';
import '/screens/windows/user_screen.dart';

import 'feed_screen.dart';
import 'notification_screen.dart';

class Window extends StatelessWidget{
  final BoxConstraints cons;
  final int viewIndex;



  Widget getUpdatedView(int index) {
    switch (index) {
      case 0:
        return const FeedScreen(key: Key('feeds-view'),);
      case 1:
        return const SearchScreen();
      case 2:
        return const Text('view3');
      case 3:
        return const UserScreen();
      default:
        return const NotificationScreen();
    }
  }

  const Window({super.key, required this.cons, required this.viewIndex});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      key: const Key('current_window_view'),
      alignment: Alignment.center,
      width: cons.maxWidth,
      height: cons.maxHeight,
      child: AnimatedSwitcher(
        reverseDuration: const Duration(milliseconds: 200),
        key: const Key('animated_transition_windows'),
        duration: const Duration(milliseconds: 350),
        child: getUpdatedView(viewIndex),
        transitionBuilder: (wid,widAnimation){
          return FadeTransition(opacity: widAnimation,child: wid,);
        },
      ),
    );
  }
}