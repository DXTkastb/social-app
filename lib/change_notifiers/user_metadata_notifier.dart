import 'dart:isolate';

import 'package:flutter/material.dart';

import '../data/user_details.dart';
import '../rsocket-engine/risolate_service/communication_data/story.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class UserMetaDataNotifier extends ChangeNotifier {
  String accountName;
  int postsCount;
  int followerCount;
  int followingCount;
  late Future<void> getMemoriesFuture;
  List<Story> memoryStories = [];
  bool _disposed = false;

  UserMetaDataNotifier(
      {required this.accountName,
      required this.postsCount,
      required this.followerCount,
      required this.followingCount});

  void init() {
    getMemoriesFuture = getMemories();
  }

  void refreshMetaData() async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'REFRESH_METADATA',
      'data': {
        'accountName': accountName,
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if (!_disposed) {
      if (list.isEmpty) {

      } else {
        var metadata = list[0] as User;
        postsCount = metadata.postsCount;
        followerCount = metadata.followerCount;
        followingCount = metadata.followingCount;
        notifyListeners();
      }
    }
  }

  Future<void> getMemories() async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_USER_MEMORIES_SET',
      'data': {
        'accountName': accountName,
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if (!_disposed) {
      if (list.isEmpty) {

      } else {
        var us = list[0];
        memoryStories = us.list;
      }
    }
  }

  void appStateChangeNotify(User user) {
    postsCount = user.postsCount;
    followerCount = user.followerCount;
    followingCount = user.followingCount;
    notifyListeners();
  }

  // void updateFollowingCount(int count){
  //   followingCount = count;
  //   notifyListeners();
  // }
  //
  // void updatePostsCount(int count){
  //   postsCount = count;
  //   notifyListeners();
  // }
  //
  // void updateFollowerCount(int count){
  //   followerCount = count;
  // }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
  }
}
