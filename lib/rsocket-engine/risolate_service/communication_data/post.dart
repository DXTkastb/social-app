class Post {

  final int postid;
  final String? caption;
  final String accountname;
  final String imgurl;
  final int ctime;
  Post(this.postid, this.caption, this.accountname, this.imgurl, this.ctime);

  static Post fromDynamicMap(dynamic map){
    return Post(map['postid'], map['caption'], map['accountname'], map['imgurl'], ((((map['ctime'] as List)[1])/1000000000)).toInt());
  }

  static Post random(){
    return Post(4254, 'All I want is nothing more.','Mark','img_url', 4536753534);
  }

  @override
  String toString() {
    return 'Post Data   => id:$postid caption:$caption accountname:$accountname imgurl:$imgurl time_created:$ctime'  ;
  }
}