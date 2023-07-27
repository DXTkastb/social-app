import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/communication_lib.dart';

import '../rsocket-engine/risolate_service/communication_data/follower_story.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class NewFollowerStoriesSet extends ChangeNotifier {
  late String accountName;
  StreamSubscription? streamSubscription;
  late Future<void> futureFetchStories;
  List<String> accountNames = [];
  bool _disposed = false;
  Timer? periodicFetchTimer;

  void init(String accountName) {
    this.accountName = accountName;
    futureFetchStories = fetchStories();
  }

  Future<void> fetchStories() async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_LATEST_USER_STORIES',
      'data': {
        'accountName': accountName,
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;

    port.close();
    if (list.isNotEmpty) {
      List<String> data = list[0];
      if (data.isNotEmpty) {
        accountNames = data;
        notifyListeners();
      }
      Future(() {
        if (!_disposed) {
          streamSubscription =
              MainIsolateEngine.engine.rPostForStoriesStream.listen((event) {
            if (!_disposed) {
              periodicFetchTimer!.cancel();
              var newlist = event as List;
              if(newlist.isNotEmpty) {
                List<String> newdata = newlist[0];
                if(newdata.isNotEmpty) {
                  accountNames = newdata;
                  notifyListeners();
                }
                setNewTimer();
              }
            }
          });
        }
      });
      setNewTimer();
    }
  }

  void setNewTimer() {
    periodicFetchTimer = Timer(const Duration(seconds: 30), () {
      if (!_disposed) {
        MainIsolateEngine.engine.sendMessage({
          'operation': 'FETCH_LATEST_USER_STORIES',
          'data': {
            'accountName': accountName,
          },
          'temp_port': MainIsolateEngine.engine.rPostForStories.sendPort
        });
      }
    });
  }

  void pauseStream() {
    streamSubscription!.pause();
  }

  void resumeStream() {
    streamSubscription!.resume();
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    if (periodicFetchTimer != null) {
      periodicFetchTimer!.cancel();
    }
    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }
  }
}
