class LatestNotificationViewQuery {
  final String accountName;
  final String notificationId;
  LatestNotificationViewQuery(this.accountName, this.notificationId);

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map ={};
    map['accountName']=accountName;
    map['notificationId']=notificationId;
    return map;
  }

  static LatestNotificationViewQuery getDummy(){
    return LatestNotificationViewQuery('dxtk','645646465');
  }
}