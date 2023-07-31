import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/component_widgets/general_image_widget.dart';
import 'package:socio/component_widgets/general_profile_image.dart';
import 'package:socio/routes/router.dart';

import '../../../component_widgets/normal_circular_indicator.dart';
import '/change_notifiers/user_notifications_notifier.dart';
import '/configs/ScrollConfig.dart';
import '../../../rsocket-engine/risolate_service/communication_data/ui_notification.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<UserNotificationsNotifier>(context, listen: false)
          .initialNotificationLoad,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {

          if(snapshot.data == 0){
            return const Center(child: Text('some error occured!'),);
          }

          return const CustomAnimatedList();
        }
        return const Center(
          child: NormalCircularIndicator());
      },
    );
  }
}

// const Notification(accountname: "DXTK", postID: 41534631, notificationType: NotificationType.LIKED,time: '2d',);

class CustomAnimatedList extends StatefulWidget {
  const CustomAnimatedList({super.key});

  @override
  State<CustomAnimatedList> createState() => _CustomAnimatedListState();
}

class _CustomAnimatedListState extends State<CustomAnimatedList> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late StreamSubscription subscriptionStream;
  late ScrollController scrollController;
  int loaded = 1;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var provider =
        Provider.of<UserNotificationsNotifier>(context, listen: false);
    subscriptionStream = provider.notificationStream.listen((event) {
      if (mounted) {
        provider.updateLatestViewedId();
        _listKey.currentState
            ?.insertItem(0, duration: const Duration(milliseconds: 350));
      }
    });
    //  Provider.of<UserNotificationsNotifier>(context, listen: true)
  }

  @override
  void dispose() {
    super.dispose();
    subscriptionStream.cancel();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfig(),
      child: Consumer<UserNotificationsNotifier>(
        builder: (ctx, unn, child) {
          if(unn.getNotificationsList().isEmpty) return const Center(child: Text('No Notifications'),);
          /*
          *  Creating new AnimatedList as multiple inserts at once is not possible.
          * */
          int eL = unn.extraLoad;
          if (eL > 0 && scrollController.hasClients) {
            _listKey = GlobalKey<AnimatedListState>();
            var extreme = scrollController.position.maxScrollExtent;
            scrollController.dispose();
            scrollController = ScrollController(initialScrollOffset: extreme);
            unn.loadComplete();
            Future.delayed(Duration.zero, () {
              if (ctx.mounted && scrollController.hasClients) {
                scrollController.animateTo((extreme + eL * 65),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.ease);
              }
            });
          }
          return AnimatedList(
              // physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
              controller: scrollController,
              key: _listKey,
              initialItemCount: unn.getNotificationsList().length,
              itemBuilder: (_, index, animation) {
               // UiNotification nm = unn.getNotificationsList()[unn.getNotificationsList().length - 1 - index];
                UiNotification nm = unn.getNotificationsList()[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: Notification(
                    accountname: nm.accountname,
                    postID: nm.postid,
                    notificationType: nm.typeOfNotification,
                    timeCreated: nm.timeCreated,
                    notificationText: nm.notificationText,
                  ),
                );
              });
        },
      ),
    );
  }
}

class Notification extends StatelessWidget {
  final String accountname;
  final int? postID;
  final int notificationType;
  final String timeCreated;
  final String notificationText;

  const Notification(
      {super.key,
      required this.accountname,
      required this.postID,
      required this.notificationType,
      required this.timeCreated,
      required this.notificationText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          // color: Color.fromRGBO(206, 171, 246, 1.0),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      margin: const EdgeInsets.only(top: 10),
      height: 55,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GeneralAccountImage(
            accountName: accountname,
            size: 40,
          ),
          const SizedBox(
            width: 7,
          ),
          // Container(
          //   margin: const EdgeInsets.all(7),
          //   height: 40,
          //   width: 40,
          //   alignment: Alignment.center,
          //   decoration: const BoxDecoration(
          //       color: Colors.black,
          //       borderRadius: BorderRadius.all(Radius.circular(25))),
          // ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                      text: "$accountname ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: "$notificationText "),
                  TextSpan(
                      text: timeCreated,
                      style: const TextStyle(
                        fontSize: 11,
                          color: Color.fromRGBO(156, 136, 171, 1.0))),
                ],
              ),
            ),
          ),
          (postID == null) ? const SizedBox() :
          GestureDetector(
              onTap: (){
                Navigator.of(context).pushNamed(AppRoutePaths.postViewRoute,arguments : [false,postID]);
              },
              child: GeneralImageWidget(imageUrl: "http://192.168.29.136:8080/post-image/wip/$postID",errorIcon: Icons.image_rounded, size: 40)),
        ],
      ),
    );
  }
}
