

class FetchStoryQuery {
  final String accountName;
  final int instant1;
  final int instant2;
  final String viewerName;

  FetchStoryQuery(
      this.accountName, this.instant1, this.instant2, this.viewerName);

  Map toMap() {
    Map<String, dynamic> map = {};
    map["instant1"] = instant1;
    map["instant2"] = instant2;
    map["accountName"] = accountName;
    map["viewerName"] = viewerName;
    return map;
  }

  static FetchStoryQuery getDummy() {
    return FetchStoryQuery(
        "dxtk",
        (DateTime.now().millisecondsSinceEpoch ~/ 1000 - 86400),
        (DateTime.now().millisecondsSinceEpoch ~/ 1000),
        "dxtk");
  }
}
