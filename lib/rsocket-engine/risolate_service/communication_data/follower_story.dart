
class FollowerStory {
  final double? score;
  bool viewedAll;
  FollowerStory(this.score, this.viewedAll);

  static FollowerStory fromDynamicMap(dynamic e){
    return FollowerStory(e['score'], e['viewedAll']);
  }

  void setViewedAll() {
    viewedAll = true;
  }


}