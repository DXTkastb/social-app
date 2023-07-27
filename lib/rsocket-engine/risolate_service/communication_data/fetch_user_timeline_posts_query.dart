class FetchUserTimelinePostsQuery {
  final String accountname;
  // final List<int> postlist;
  final int maxIndex;
  final int minIndex;
  FetchUserTimelinePostsQuery(this.accountname, this.maxIndex, this.minIndex);

  Map toMap() {
    Map<String, dynamic> map = {};
    map["maxIndex"] = maxIndex;
    map["minIndex"] = minIndex;
    map["accountname"] = accountname;
    return map;
  }

  static FetchUserTimelinePostsQuery getDummy(){
    return FetchUserTimelinePostsQuery('amber',-1,-1);
  }
}