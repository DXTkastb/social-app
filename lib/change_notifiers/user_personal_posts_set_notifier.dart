import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/communication_lib.dart';

import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class UserPersonalPostSet extends ChangeNotifier {

  late Future<void> fetchUserPosts;
  late String accountName;
  late List<Post> userposts;

  void init(String acname) {
    userposts = [];
    accountName = acname;
    fetchUserPosts = fetchCurrentUserPosts();
  }

  Future<void> fetchCurrentUserPosts() async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_USER_PERSONAL_POSTS',
      'data': {
        'accountName': accountName,
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if (list.isEmpty) {

    } else {
      var us = list[0];
      userposts = us.posts;
    }
  }

  void appStateChangeNotify(String acname){
    if(acname != accountName){
      init(acname);
      notifyListeners();
    }
  }

  void uploadedNewPost(Post post){
    userposts.insert(0, post);
    notifyListeners();
  }

  void deletePost(int postId){
    if(userposts.isEmpty) return;
    int index = -1;
    for(var p in userposts){
      index++;
      if(p.postid == postId)
        break;
    }
    userposts.removeAt(index);
    notifyListeners();
  }

}
