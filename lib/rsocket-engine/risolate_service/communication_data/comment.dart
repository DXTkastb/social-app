
class Comment {
  final int commentid;
  final int onpostid;
  final String text;
  final String accountname;
  final Future? userAddProgress;
  Comment(this.commentid, this.onpostid, this.text, this.accountname, this.userAddProgress);
}
