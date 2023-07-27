
class FetchStorySetQuery {
  final String accountName;
  final int instant1;
  final int instant2;
  FetchStorySetQuery(this.accountName, this.instant1, this.instant2);

  static FetchStorySetQuery getDummyForUserSetStories(){
    return FetchStorySetQuery("amber", (DateTime.now().millisecondsSinceEpoch~/1000), (DateTime.now().millisecondsSinceEpoch~/1000));
  }
  static FetchStorySetQuery getDummyForUserNewSetStories(){
    return FetchStorySetQuery("amber", (DateTime.now().millisecondsSinceEpoch~/1000 - 86400), (DateTime.now().millisecondsSinceEpoch~/1000));
  }
  Map toMap() {
    Map<String, dynamic> map = {};
    map["instant1"] = instant1;
    map["instant2"] = instant2;
    map["accountName"] = accountName;
    return map;
  }

}