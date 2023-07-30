import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../rsocket-engine/risolate_service/communication_data/story.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class UserPersonalStoryNotifier extends ChangeNotifier {
  late String accountName;
  late List<Story> currentStories;

  // late bool hasStories;
  late Future<void> fetchCurrentStoryFuture;

  void init(String acname) {
    accountName = acname;
    currentStories = [];
    // hasStories = false;
    fetchCurrentStoryFuture = fetchCurrentStories();
  }

  Future<void> fetchCurrentStories() async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_USER_CURRENT_STORIES',
      'data': {
        'accountName': accountName,
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    if(list.isNotEmpty) {
      currentStories = list[0] as List<Story>;
    }
  }

//
// Future<void> fetchCurrentStories() async {
//   var port = ReceivePort();
//   int timeEpoch = DateTime.now().millisecondsSinceEpoch~/1000;
//   var output = port.first;
//
//
//   MainIsolateEngine.engine.sendMessage({
//     'operation': 'FETCH_USER_CURRENT_STORIES',
//     'data': {
//       'accountName': accountName,
//       'instant2': timeEpoch,
//       'instant1': timeEpoch - 86400,
//       'viewerName': accountName
//     },
//     'temp_port': port.sendPort
//   });
//   var list = (await output) as List;
//   port.close();
//   if (list.isEmpty) {
//     if (kDebugMode) {
//
//     }
//   } else {
//     var us = list[0];
//     currentStories = us.stories;
//     hasStories = currentStories.isNotEmpty;
//   }
// }
//
void appStateChangeNotify(String acname) {
  if (accountName != acname) {
    init(acname);
    notifyListeners();
  }
}

void addUploadedStory(Story story){
  currentStories.insert(0, story);
  // hasStories = true;
  notifyListeners();
}


}
