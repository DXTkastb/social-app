
class ExternalUserQuery {
  final String accountName;
  final String searchedAccountName;
  ExternalUserQuery(this.accountName, this.searchedAccountName);
  static ExternalUserQuery getDummy(){
    return ExternalUserQuery("amber", "dxtk");
  }

  Map<String,dynamic> toMap() {
    Map<String,dynamic> map = {};
    map['accountName']=accountName;
    map['searchedAccountName']=searchedAccountName;
    return map;
  }
}