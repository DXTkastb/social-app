import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/change_notifiers/user_notifications_notifier.dart';

class NotificationsNavButton extends StatelessWidget {
  final int index;
  final bool isActive;
  final Function(int i) changeBarState;

  const NotificationsNavButton(
      {super.key,
      required this.isActive,
      required this.changeBarState,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          changeBarState(index);
        }
      },
      child: AnimatedContainer(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (isActive) ? Colors.deepPurple : Colors.black,
            // const Color.fromRGBO(179, 131, 255, 1.0),
            borderRadius: BorderRadius.circular(35),
          ),
          curve: Curves.linear,
          padding: const EdgeInsets.all(5),
          duration: const Duration(milliseconds: 200),
          child: FutureBuilder(
            future:
                Provider.of<UserNotificationsNotifier>(context, listen: false)
                    .initialNotificationLoad,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return StreamNotificationIcon(isActive: isActive);
              }
              return Icon(
                Icons.notifications,
                size: 21,
                color: (isActive)
                    ? Colors.white
                    : const Color.fromRGBO(204, 166, 253, 1.0)                ,
              );
            },
          )),
    );
  }
}

class StreamNotificationIcon extends StatefulWidget {
  final bool isActive;

  const StreamNotificationIcon({super.key, required this.isActive});

  @override
  State<StreamNotificationIcon> createState() => _StreamNotificationIconState();
}

class _StreamNotificationIconState extends State<StreamNotificationIcon> {
  int latest = 0;

  @override
  void didUpdateWidget(StreamNotificationIcon oldWidget) {
    if (oldWidget.isActive) {
      int anyNew =
          Provider.of<UserNotificationsNotifier>(context, listen: false)
              .hasNewNotifications;
      latest = latest > anyNew ? latest : anyNew;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      initialData: 0,
        stream: Provider.of<UserNotificationsNotifier>(context, listen: false)
            .notificationStream,
        builder: (ctx, snapshot) {
          int anyNew =
              Provider.of<UserNotificationsNotifier>(context, listen: false)
                  .hasNewNotifications;

          if (!(widget.isActive) && ((latest < anyNew))) {
            return const Icon(
              Icons.notifications_on_sharp,
              size: 21,
              color: Color.fromRGBO(245, 91, 176, 1.0),
            );
          }
          return Icon(
            Icons.notifications,
            size: 21,
            color: (widget.isActive)
                ? Colors.white
                : const Color.fromRGBO(204, 166, 253, 1.0),
          );
        });
  }
}
