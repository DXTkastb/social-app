import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/change_notifiers/user_notifications_notifier.dart';
import '/screens/windows/notification_screen_sub/notification_list.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: constraints.maxWidth,
            height: 80,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(174, 138, 255, 1.0),
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25)),
            ),
            child: const Text(
              'Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(child: NListWithDragLoadWidget()),
        ],
      );
    });
  }
}

class NListWithDragLoadWidget extends StatelessWidget {
  const NListWithDragLoadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var provider =
    Provider.of<UserNotificationsNotifier>(context, listen: false);
    return NotificationListener<OverscrollNotification>(
      onNotification: (notification){
      if (notification.dragDetails != null && notification.dragDetails!.delta.dy < 0) {
          provider.loadMoreOldNotifications();
      }
        return true;
      },
      child: const Stack(
        children: [
          NotificationList(),
          Positioned(
            bottom: 0,
            left: 10,
            right: 10,
            child: AnimatedLoadBar(),
          ),
        ],
      ),
    );
  }
}

class AnimatedLoadBar extends StatefulWidget {
  const AnimatedLoadBar({super.key});

  @override
  State<AnimatedLoadBar> createState() => _AnimatedLoadBarState();
}

class _AnimatedLoadBarState extends State<AnimatedLoadBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotificationsNotifier>(
      builder: (ctx, value, child) {
        return AnimatedContainer(
          key: const Key('loading-animation'),
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: (!value.oldNotificationsAvailable) ? Colors.orange : Colors.green,
            borderRadius: const BorderRadius.only(
              topRight: Radius.elliptical(550, 100),
              topLeft: Radius.elliptical(550, 100),
            ),
          ),
          height: (value.loadingOldNotifications) ? 4 : 0,

        );
      },
    );
  }
}
