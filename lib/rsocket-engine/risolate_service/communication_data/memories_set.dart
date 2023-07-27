import 'story.dart';

class MemoriesSet {
  late final List<Story> list;
  MemoriesSet({required Object listData}){
    list = [];
    listData = listData as List;
    for (var element in listData) {
      Story story = Story.fromDynamicMap(element);
      list.add(story);
    }
  }
}