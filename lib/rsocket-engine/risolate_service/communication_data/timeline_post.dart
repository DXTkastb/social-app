import 'post.dart';

class TimelinePost extends Post{
  int likesCount;
  bool liked;

  TimelinePost(super.postid, super.caption, super.accountname, super.imgurl, super.ctime, this.likesCount,this.liked);
  static TimelinePost fromDynamicMap(dynamic map){
    return TimelinePost(map['postid'], map['caption'], map['accountname'], map['imgurl'], ((((map['ctime'] as List)[1])/1000000000)).toInt(),map['likesCount'],(map['liked']==1));
  }

  static TimelinePost random(){
    return TimelinePost(4254, 'All I want is nothing more.','Mark','img_url', 4536753534,345353,true);
  }

  void like (){
    likesCount++;
  }
  void unlike(){
    likesCount--;
  }

}