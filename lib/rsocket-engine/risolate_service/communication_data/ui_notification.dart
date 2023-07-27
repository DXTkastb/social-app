class UiNotification {
  final String accountname;

  /*
	 * type => 0: liked   1: commented    2: followed
	 */
  final int? postid;
  final String timeCreated;
  final String id;
  final String notificationText;
  final int typeOfNotification;

  UiNotification(this.accountname, this.postid, this.timeCreated, this.id,
      this.notificationText, this.typeOfNotification);

  static UiNotification fromMapData(Map x) {
    return UiNotification(x['accountname'], x['postid'], x['timeCreated'],
        x['id'], x['notificationText'], x['type']);
  }

  @override
  String toString() {
    return "$accountname : $postid : $timeCreated : $id : $notificationText : $typeOfNotification";
  }
}

class UiNotificationMessages {
  List<UiNotification> list = [];
  int newNotificationCount = 0;

  UiNotificationMessages({required Object objects}) {
    objects = objects as Map;
    newNotificationCount = objects['newNotificationCount'] as int;
    list = (objects['uiMessages'] as List).map((e) {
      var x = (e! as Map);
      return UiNotification(x['accountname'], x['postid'], x['timeCreated'],
          x['id'], x['notificationText'], x['type']);
    }).toList(growable: false);
  }

  @override
  String toString() {
    return 'UiNotificationMessages{list: $list, newNotificationCount: $newNotificationCount}';
  }
}
