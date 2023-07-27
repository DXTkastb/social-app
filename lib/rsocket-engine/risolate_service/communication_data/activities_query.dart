
class ActivityQuery {
  final String accountname;
  final String postCreatorName;
  final int onpostid;
  ActivityQuery(this.onpostid,  this.accountname, this.postCreatorName);
}

class CommentActivityQuery extends ActivityQuery{

  final String text;

  CommentActivityQuery(super.onpostid, super.accountname, super.postCreatorName, this.text);
  static CommentActivityQuery fromDummy(){
    return CommentActivityQuery(2,  'amber', 'dxtk','this is caption',);
  }
  Map<String,dynamic> toMap(){
    Map<String,dynamic> map = {};
    map['onpostid']=onpostid;
    map['text'] = text;
    map['accountname']=accountname;
    map['postCreatorName']=postCreatorName;
    return map;
  }
}

class LikeActivityQuery extends ActivityQuery {

  LikeActivityQuery(super.onpostid, super.accountname, super.postCreatorName,);
  static LikeActivityQuery fromDummy(){
    return LikeActivityQuery(2, 'amber', 'dxtk');
  }
  Map<String,dynamic> toMap(){
    Map<String,dynamic> map = {};
    map['onpostid']=onpostid;
    map['accountname']=accountname;
    map['postCreatorName']=postCreatorName;
    return map;
  }
}