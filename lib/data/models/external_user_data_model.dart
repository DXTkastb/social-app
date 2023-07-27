import 'dart:isolate';

import 'package:socio/rsocket-engine/risolate_service/communication_data/communication_lib.dart';
import '../../rsocket-engine/risolate_service/main_isolate_engine.dart';


class ExternalUserDataModel {
  final String searchAccountName;
  late Future<void> dataLoadFuture;
  late Future<void> postsLoadFuture;
  late Future<void> memoriesLoadFuture;
  List<Post> userposts = [];
  List<Story> storyMemories = []; // test testing its just pic ids from Picsum.com
  User user;
  bool _disposed = false;
  bool didChange = false;

  ExternalUserDataModel({required this.user,required this.searchAccountName});

  void init() {
    dataLoadFuture = getData();
    postsLoadFuture = getPostData();
    memoriesLoadFuture = getStories();
  }

  void updateFollowing(){
    user.follow = !user.follow;
    if(!didChange) didChange = true;
  }

  Future<void> getData() async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_EXTERNAL_USER_DETAILS',
      'data': {
        'accountName': searchAccountName,
        'searchedAccountName': user.accountname
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if(!_disposed){
      if (list.isEmpty) {

      } else {
        user = list[0];
      }
    }
  }

  Future<void> getPostData() async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_USER_PERSONAL_POSTS',
      'data': {
        'accountName': user.accountname,
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if(!_disposed)
    {
      if (list.isEmpty) {

      } else {
        var us = list[0];
        userposts = us.posts;
      }
    }
  }

  Future<void> getStories() async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_USER_MEMORIES_SET',
      'data': {
        'accountName': user.accountname,
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if(!_disposed)
    {
      if (list.isEmpty) {

      } else {
        var us = list[0];
        storyMemories = us.list;
      }
    }
  }

  void dispose() {
    _disposed = true;
  }
}
