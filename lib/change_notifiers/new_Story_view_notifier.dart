import 'dart:isolate';

import 'package:flutter/material.dart';

import '../rsocket-engine/risolate_service/communication_data/story.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class NewStoryViewNotifier extends ChangeNotifier {
  final String accountName;

  NewStoryViewNotifier(this.accountName);

  int currentIndex = 0;
  bool _disposed = false;
  late Future<void> future;
  late final List<Story> stories;
  Set<int> storiesViewed = {};
  Set<int> storiesUnseen = {};
  bool fromMemory = false;

  void init(String viewerName,int instant1, int instant2) {
    future = fetchUserStories(viewerName, instant1, instant2);
  }

  void initWithUserMemories(int x) {
    fromMemory = true;
    future = fetchMemoryStories(x);
  }

  void initForCurrentUser(List list) {
    future = Future(() {
      stories = list as List<Story>;
    });
  }

  Future<void> fetchUserStories(String viewerName,int instant1, int instant2) async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_EXTERNAL_USER_STORIES',
      'data': {
        'accountName': accountName,
        'instant2': instant2,
        'instant1': instant1,
        'viewerName': viewerName
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if (list.isEmpty) {

    } else {
      var us = list[0];
      stories = us.stories;
      storiesUnseen = us.unSeenStoriesId;
    }
  }

  Future<void> fetchMemoryStories(int memoryId) async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_MEMORY_STORIES',
      'data': {
        'memoryId': memoryId,
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if (list.isEmpty) {

    } else {
      var us = list[0];
      stories = us.stories;
      storiesUnseen = us.unSeenStoriesId;
    }
  }

  void incrementIndex() {
    currentIndex = currentIndex + 1;
    notifyListeners();
  }

  Story getStoryByIndex(int index) {
    Story story = stories[index];
    Future(() {
      if (!_disposed) {
        if (storiesUnseen.contains(story.storyid)) {
          storiesViewed.add(story.storyid!);
          storiesUnseen.remove(story.storyid!);
        }
      }
    });
    return story;
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;

    // if (storiesViewed.isNotEmpty) {
    //   Future(() {
    //     /*
    //      if memory then return
    //      push all unseen stories viewed to redis server.
    //      If unseenStoriesCount == 0, push highest timestamp(score) story to redis user's seen sortedset
    //      */
    //   });
    // }
  }
}
