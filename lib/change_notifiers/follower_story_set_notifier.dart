import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/communication_lib.dart';

import '../rsocket-engine/risolate_service/communication_data/follower_story.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class FollowerStoriesSets extends ChangeNotifier {
  late String accountName;
  late int instant1;
  late int instant2;
  StreamSubscription? streamSubscription;
  late Future<void> futureFetchStories;
  Map<String, FollowerStory> userStorySet = {};
  bool _disposed = false;
  Timer? periodicFetchTimer;

  void init(String accountName) {
    this.accountName = accountName;
    instant2 = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 5;
    instant1 = instant2 - 86400;
    futureFetchStories = fetchStories();
  }

  Future<void> fetchStories() async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_USER_STORIES_SET',
      'data': {
        'accountName': accountName,
        'instant2': instant2,
        'instant1': instant1,
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if (list.isEmpty) {

      // now wait for app refresh!
    } else {
      var us = list[0];
      userStorySet = us.data;
      Future(() {
        if (!_disposed) {
          streamSubscription =
              MainIsolateEngine.engine.rPostForStoriesStream.listen((event) {
            if (!_disposed) {
              var list = (event as List);
              periodicFetchTimer!.cancel();
              if (list.isEmpty) {
                return;
                // now wait for app refresh!
              }
              var newStorySet = list[0];
              var sData = newStorySet.data as Map<String, FollowerStory>;
              userStorySet.addAll(sData);
              if (!_disposed) {
                notifyListeners();
              }
              setNewTimer();
            }
          });
          setNewTimer();
        }
      });
    }
  }

  void setNewTimer() {
    periodicFetchTimer = Timer(const Duration(seconds: 15), () {
      if (!_disposed) {
        instant1 = instant2;
        instant2 = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 5;
        MainIsolateEngine.engine.sendMessage({
          'operation': 'FETCH_USER_STORIES_NEW_SET',
          'data': {
            'accountName': accountName,
            'instant2': instant2,
            'instant1': instant1,
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
    if(periodicFetchTimer!=null) {
      periodicFetchTimer!.cancel();
    }
    if(streamSubscription != null)
    streamSubscription!.cancel();
  }
}
