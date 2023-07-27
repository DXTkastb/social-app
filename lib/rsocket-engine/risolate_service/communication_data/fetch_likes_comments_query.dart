
class FetchLikeCommentQuery {
  final int postid;
  final int? lastFetchId;
  FetchLikeCommentQuery(this.postid, this.lastFetchId);
  Map<String,dynamic> toMap(){
    Map<String,dynamic> map ={};
    map['postid']=postid;
    map['lastFetchId']=lastFetchId;
    return map;
  }

  static FetchLikeCommentQuery getDummy(){
    return FetchLikeCommentQuery(46846514,545648961);
  }
}