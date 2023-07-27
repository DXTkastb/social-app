

import 'post.dart';

class UserPersonalPosts {
  late final List<Post> posts;

  UserPersonalPosts({required Object dataMap}) {
    var map = dataMap as Map;
    List<Object?> dataList = map['userPersonalPosts'];
    posts = [];
    for (var element in dataList) {
      posts.add(Post.fromDynamicMap(element as Map));
    }
  }
}
