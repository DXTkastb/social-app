
class UserStoryViewersList {
  late final List<String> data;
  UserStoryViewersList({required Object listData}){
    data = (listData as List).map((e) => e! as String).toList(growable: false);
  }
}