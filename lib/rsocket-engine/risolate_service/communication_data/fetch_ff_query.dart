class FetchFFQuery {
  final String? accountName;
  final String? lastAccountName;
  FetchFFQuery(this.accountName, this.lastAccountName);

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map ={};
    map['accountName']=accountName;
    map['lastAccountName']=lastAccountName;
    return map;
  }
}