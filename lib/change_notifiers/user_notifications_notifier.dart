import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

import '../rsocket-engine/risolate_service/communication_data/ui_notification.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class UserNotificationsNotifier extends ChangeNotifier {
  int extraLoad = 0;
  bool canLoadMore = true;
  bool fetchCompleted = false;
  bool loadingOldNotifications = false;
  bool oldNotificationsAvailable = false;
  late Future<int> initialNotificationLoad;
  final List<UiNotification> _notifications = [];
  int hasNewNotifications = 0;
  int newNotificationCounter = 0;
  late int totalFetchedNotifications = -1;
  StreamController<int> streamController = StreamController();
  late Stream<int> notificationStream;
  String accountName;
  late final StreamSubscription? rsocketNewNotificationsSubscription;

  bool _disposed = false;

  UserNotificationsNotifier({required this.accountName});

  void init() {
    initialNotificationLoad = getNotifications();
    notificationStream = streamController.stream.asBroadcastStream();
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_USER_NOTIFICATIONS',
      'data': {
        'accountName': accountName,
      },
      'temp_port': MainIsolateEngine.engine.rNotification.sendPort
    });
    // IsolateMessagingService.rNotification as Stream<NotificationObj>;
  }

  Future<int> getNotifications() async {
    var nData = await MainIsolateEngine.engine.rNotificationStream.first;
    fetchCompleted = true;
    nData = nData as List;
    if (nData.isEmpty) {
      return 0;
    }

    List<UiNotification> newLoaded = nData[0].list;
    newNotificationCounter = nData[0].newNotificationCount;
    hasNewNotifications = newNotificationCounter;
    totalFetchedNotifications = newLoaded.length;
    if (totalFetchedNotifications < 35) {
      canLoadMore = false;
    }
    _notifications.addAll(newLoaded);
    subscribeToNewNotifications();
    return 1;
  }

  void subscribeToNewNotifications() {
    Future.delayed(Duration.zero, () {
      if (_disposed) return;
      rsocketNewNotificationsSubscription =
          MainIsolateEngine.engine.rNotificationStream.listen((event) {
        if (!_disposed) {
          event = event as List;

          if (event.isEmpty) return; // some error occured
          if (fetchCompleted) {
            // || (event.first as UiNotificationMessages).list.isEmpty) return;
            // FOR SERVER PUSHED NOTIFICATIONS !
            // add notifications to _notifications list
            ++hasNewNotifications;
            ++newNotificationCounter;
            _notifications.insert(0,(event.first as UiNotification));
            streamController.add(1);
          }
        }
      });
      MainIsolateEngine.engine.sendMessage({
        'operation': 'SUBSCRIBE_TO_NOTIFICATIONS',
        'data': {
          'accountName': accountName,
          'offset': (_notifications.isEmpty) ? "0" : _notifications.first.id,
        },
      });
    });
  }

  Future<void> loadMoreOldNotifications() async {
    if (!loadingOldNotifications && canLoadMore) return;
    loadingOldNotifications = true;

    notifyListeners();
    loadComplete();

    ReceivePort port = ReceivePort();

    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_OLD_NOTIFICATIONS',
      'data': {
        'accountName': accountName,
        'lastNotificationID': _notifications.last.id,
      },
      'temp_port': port.sendPort
    });

    var listData = await port.first;
    port.close();
    listData = listData as List;

    if (listData.isEmpty) {
      if (!_disposed) {
        loadingOldNotifications = false;
        notifyListeners();
      }
      return;
    } // some error occurred!

    List<UiNotification> oldNfs = listData[0];
    if (!_disposed) {
      if (oldNfs.isNotEmpty) {
        if (oldNfs.length < 25) canLoadMore = false;
        _notifications.addAll(oldNfs);
        // _notifications.insertAll(0, oldNfs);
        extraLoad = oldNfs.length;
        oldNotificationsAvailable = true;
        notifyListeners();
      } else {
        canLoadMore = false;
        loadingOldNotifications = false;
        notifyListeners();
        return;
      }
    }
    await Future.delayed(const Duration(seconds: 1));

    if (!_disposed) {
      loadingOldNotifications = false;
      notifyListeners();
      oldNotificationsAvailable = false;
    }
  }

  void loadComplete() {
    extraLoad = 0;
  }

  List<UiNotification> getNotificationsList() {
    updateLatestViewedId();
    return _notifications;
  }

  void updateLatestViewedId() {
    if (newNotificationCounter > 0) {
      Future.delayed(Duration.zero, () {
        if (!_disposed) {
          MainIsolateEngine.engine.sendMessage({
            'operation': 'UPDATE_LATEST_NOTIFICATIONS_VIEW',
            'data': {
              'accountName': accountName,
              'notificationId':
                  (_notifications.isEmpty) ? "0-0" : _notifications.first.id,
            },
          });
        }
      });
      newNotificationCounter = 0;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    streamController.close();
  }
}
