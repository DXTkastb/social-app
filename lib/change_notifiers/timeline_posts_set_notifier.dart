import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';

import '../rsocket-engine/risolate_service/communication_data/timeline_post.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class TimelinePostsNotifier extends ChangeNotifier {
  late StreamController<bool> _streamController;
  late Timer timer;
  late bool _disposed;
  late ScrollController scrollController;
  late List<TimelinePost> posts;
  late Future getTimelinePostsFuture;
  late bool canLoadMore;
  late bool loadingMore;
  late List<TimelinePost> newPostsLoaded;
  late String accountName;
  late Stream<bool> updateStream;
  late bool _userUploadedPost;
  StreamSubscription? streamSubscription;
  int minIndex = -1;
  int maxIndex = -1;

  void init(String acname) {
    canLoadMore = true;
    loadingMore = false;
    accountName = acname;
    getTimelinePostsFuture = initFuture();
    scrollController = ScrollController();
    newPostsLoaded = [];
    posts =[];
    _disposed = false;
    _disposed = false;
    _userUploadedPost = false;
    _streamController = StreamController();
    updateStream = _streamController.stream.asBroadcastStream();
  }

  Future<void> initFuture() async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_USER_TIMELINE_POSTS',
      'data': {
        'accountName': accountName,
        'maxIndex': -1,
        'minIndex': -1
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if (list.isEmpty) {
      if(!_disposed)
        if(posts.isEmpty);
    } else {
      var us = list[0];
      posts.addAll(us.userPosts);
      if(posts.length<30) canLoadMore = false;
      minIndex = us.minIndex;
      maxIndex = us.maxIndex;
      streamSubscription =
          MainIsolateEngine.engine.rPostForPostsStream.listen((event) {
        if (!_disposed) {
          if (event.isEmpty) {

          } else {
            var x = event[0];
            // If new posts are loaded!
            if (x.minIndex == -1) {
              newPostsLoaded.addAll(x.userPosts);
              if (newPostsLoaded.isNotEmpty) {
                maxIndex = x.maxIndex;
                _streamController.add(true);
              } else {
                Future(() {
                  updateTimer();
                });
              }
            }
            // if old posts are loaded
            else if (x.maxIndex == -1) {
              List oldPosts = (x.userPosts as List);
              if (oldPosts.isNotEmpty) {
                posts.addAll(x.userPosts);
                minIndex = x.minIndex;
              }
              if(oldPosts.length<35){
                if (canLoadMore) {
                  canLoadMore = false;
                }
              }
              notifyListeners();
              loadingMore = false;
            }
          }
        }
      });
    }
    setNewTimer();
  }

  void getNewData() async {
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_USER_TIMELINE_POSTS',
      'data': {
        'accountName': accountName,
        'maxIndex': maxIndex,
        'minIndex': -1
      },
      'temp_port': MainIsolateEngine.engine.rPortForPosts.sendPort
    });
  }

  void setNewTimer() {
    Duration duration;
    if (_userUploadedPost) {
      duration = Duration.zero;
    } else {
      duration = const Duration(seconds: 5);
      _userUploadedPost = false;
    }
    timer = Timer(duration, () {
      if (!_disposed) getNewData();
    });
  }

  void uploadedNewPost() {
    // if (newPostsLoaded.isNotEmpty) {
      _userUploadedPost = true;
    // }
  }

  void updateTimer() {
    timer.cancel();
    setNewTimer();
  }

  void appStateChangeNotify(String acname) {
    if (acname != accountName) {
      scrollController.dispose();
      _streamController.close();
      init(acname);
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (loadingMore || !canLoadMore) return;
    loadingMore = true;
    await Future.delayed(const Duration(seconds: 1));
 //   print('fetching old posts with min:$minIndex max:$maxIndex');
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_USER_TIMELINE_POSTS',
      'data': {
        'accountName': accountName,
        'maxIndex': -1,
        'minIndex': minIndex
      },
      'temp_port': MainIsolateEngine.engine.rPortForPosts.sendPort
    });
  }

  void updateFeedsList() {
    if (newPostsLoaded.isEmpty) return;
    posts.addAll(newPostsLoaded);
    newPostsLoaded = [];
    notifyListeners();
    updateTimer();
  }

  void postDeleted(int postid){
    int index = -1;
    for(int i=0;i<posts.length;i++){
      if(posts[i].postid == postid)
        {
          index = i;
        }
    }
    if(index!=-1){
      posts.removeAt(index);
      notifyListeners();
      return;
    }
    for(int i=0;i<newPostsLoaded.length;i++){
      if(newPostsLoaded[i].postid == postid)
      {
        index = i;
      }
    }
    if(index!=-1){
      newPostsLoaded.removeAt(index);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
    if(streamSubscription!=null) {
      streamSubscription!.cancel();
    }
    _disposed = true;
  }
}
