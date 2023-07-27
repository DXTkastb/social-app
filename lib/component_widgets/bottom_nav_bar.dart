import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '/component_widgets/bottom_add_sheet.dart';

import 'notification_nav_button.dart';

class BottomNavBar extends StatefulWidget {
  final void Function(int x) updateCurrentView;
  const BottomNavBar({super.key, required this.updateCurrentView});

  @override
  State<StatefulWidget> createState() {
    return BottomNavBarState();
  }
}

class BottomNavBarState extends State<BottomNavBar> {
  /*  Indexing
      0 :   feeds
      1 :   search
      2 :   add post
      3 :   user
      4 :   notifications
   */

  int barIndex = 0;

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage != null){
      _handleFirebaseNotificationMessages(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleFirebaseNotificationMessages);
  }

  void _handleFirebaseNotificationMessages(RemoteMessage rm){
    if(rm.data['type'] == 'notification' && mounted)
    {
      updateBarState(4);
    }
  }

  void updateBarState(int index) {
    setState(() {
      barIndex = index;
    });
    widget.updateCurrentView(index);
  }

  bool isButtonActive(int num) {
    return barIndex == num;
  }


  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 6, left: 6, right: 6, top: 0),
      decoration: const BoxDecoration(
          color: Colors.black,
          // color: Color.fromRGBO(179, 131, 255, 1.0),
          borderRadius: BorderRadius.all(Radius.circular(70))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavButton(
            isActive: isButtonActive(0),
            changeBarState: updateBarState,
            icon: Icons.dynamic_feed_sharp,
            index: 0,
          ),
          NavButton(
            isActive: isButtonActive(1),
            changeBarState: updateBarState,
            icon: Icons.search_sharp,
            index: 1,
          ),
          NavButton(
            isActive: isButtonActive(2),
            changeBarState: updateBarState,
            icon: Icons.add_box_sharp,
            index: 2,
          ),
          NavButton(
            isActive: isButtonActive(3),
            changeBarState: updateBarState,
            icon: Icons.person_4_sharp,
            index: 3,
          ),
          NotificationsNavButton(
            isActive: isButtonActive(4),
            changeBarState: updateBarState,
            index: 4,
          ),
        ],
      ),
    );
  }
}

class NavButton extends StatelessWidget {
  final int index;
  final bool isActive;
  final Function(int i) changeBarState;
  final IconData icon;

  const NavButton(
      {super.key,
      required this.isActive,
      required this.changeBarState,
      required this.icon,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isActive && index != 2) {
          changeBarState(index);
        } else if (!isActive && index == 2) {
          showModalBottomSheet(
              backgroundColor: Colors.black,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.elliptical(200, 70),
                      topRight: Radius.elliptical(200,70))),
              context: context,
              builder: (_) {
                return const BottomAddSheetContainer();
              });
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
          child: Icon(
            icon,
            size: 21,
            color: (isActive)
                ? Colors.white
                : const Color.fromRGBO(204, 166, 253, 1.0)
            // const Color.fromRGBO(179, 131, 255, 1.0)
            ,
          )),
    );
  }
}
