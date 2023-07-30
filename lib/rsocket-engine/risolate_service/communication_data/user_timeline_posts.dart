import 'timeline_post.dart';

class UserTimelinePosts {
  late final List<TimelinePost> userPosts;
  late final int maxIndex;
  late final int minIndex;
  UserTimelinePosts({required Object dataMap}){
    dataMap = dataMap as Map;
    maxIndex = dataMap['maxIndex'];
    minIndex = dataMap['minIndex'];
    userPosts = (dataMap['userPosts'] as List).map((e) => TimelinePost.fromDynamicMap(e)).toList(growable: false);
  }

  @override
  String toString() {
    return 'UserTimelinePosts{userPosts: $userPosts, maxIndex: $maxIndex, minIndex: $minIndex}';
  }
}