class FetchOldNotificationsQuery {
  final String accountName;
  final String lastNotificationID;

  FetchOldNotificationsQuery(this.accountName,this.lastNotificationID);
  Map<String,dynamic> toMap(){
    Map<String,dynamic> map = {};
    map['accountName']=accountName;
    map['lastNotificationID']=lastNotificationID;
    return map;
  }
  static FetchOldNotificationsQuery getDummy(){
    return FetchOldNotificationsQuery("dxtk","65465465461");
  }
}
