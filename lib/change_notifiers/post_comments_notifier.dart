import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/comment.dart';

import '../rsocket-engine/risolate_service/communication_data/post.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class PostCommentsNotifier extends ChangeNotifier {
  bool _disposed = false;
  late final Post post;
  List<Comment> commentsList = [];
  late Future<void> getCommentsFuture;
  bool canLoadMore = true;
  bool loadingMore = false;
  bool fromComment = false;
  void init(Post p,bool fC){
    fromComment = fC;
    post = p;
    getCommentsFuture = _getFuture(true);
  }

  Future _getFuture(bool initialLoad) async {
    if (!canLoadMore && loadingMore) return;
    loadingMore = true;
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_COMMENTS',
      'data': {
        'postid': post.postid,
        'lastFetchId': (initialLoad) ? null : commentsList.last.commentid,
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if (list.isEmpty) {

    } else {
      if (!_disposed) {
        List<Comment> newLoadedComments = list[0];
        commentsList.addAll(newLoadedComments);
        loadingMore = false;
        if (newLoadedComments.length < 50) canLoadMore = false;
        if (!initialLoad) {
          notifyListeners();
        }
      }
    }

  }

  void addComment(String text,String accountName,int postid,Future addFuture){
    Comment comment = Comment(0, postid, text, accountName, addFuture);
    // UserComment comment= UserComment(accountName, text,addProgressFuture);
     commentsList.insert(0, comment);
    notifyListeners();
  }

  loadMoreComments() {
    _getFuture(false);
  }


  @override
  void dispose(){
    super.dispose();
    _disposed = true;
  }
}
