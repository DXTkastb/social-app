import 'follower_story.dart';

class UserStorySet {
  late final Map<String,FollowerStory> data;
  UserStorySet({required Object dataMap}){
    data = {};
    dataMap = dataMap as Map;
    Map mp = dataMap['data'];
      (mp).forEach((key, value) {
      var fs = FollowerStory.fromDynamicMap(value);
      data[key as String] = fs;
    });
  }
}