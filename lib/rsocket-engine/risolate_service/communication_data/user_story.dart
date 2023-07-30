import 'story.dart';

class UserStory {
  late List<Story> stories;
  late Set unSeenStoriesId;

  UserStory({required Object dataMap}) {
    Map map = dataMap as Map;
    stories =
        (map['stories'] as List).map((e) => Story.fromDynamicMap(e!)).toList();
    unSeenStoriesId = map['unseenStoriesCount']??{};
  }

}
