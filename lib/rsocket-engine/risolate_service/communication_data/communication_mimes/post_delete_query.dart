class PostDeleteQuery {
  final String accountName;
  final int postId;
  PostDeleteQuery(this.accountName, this.postId);
  static PostDeleteQuery fromDynamicMap(Map map) {
    return PostDeleteQuery(map['accountName'], map['postId']);
  }
}