
class FetchStoryViewsQuery {
  final String accontName;
  final String storyID;
  FetchStoryViewsQuery(this.accontName, this.storyID);

  Map<String,dynamic> toMap(){
      Map<String,dynamic> map = {};
      map['accontName'] = accontName;
      map['storyID'] = storyID;
      return map;
  }
  static FetchStoryViewsQuery getDummy(){
    return FetchStoryViewsQuery("dxtk","6545644");
  }

}