// class NotificationMessage {
//   final String accountname;
//   final int type;
//   final int? postid;
//   final String timeCreated;
//   final String id;
//   NotificationMessage(this.accountname, this.type, this.postid, this.timeCreated, this.id);
//
//   static NotificationMessage getDefault() {
//     return NotificationMessage('DXTK',1,46236,'2d','23261262170-0');
//   }
//   static NotificationMessage getDefault2(String s1,int id) {
//     return NotificationMessage(s1,1,id,'2d','23261262170-0');
//   }
//
//   static List<NotificationMessage> getDefaultList(){
//     List<NotificationMessage> list = [];
//
//     for(int i=0;i<5;i++) {
//       list.add(getDefault2(
//         'DXTK$i',i*2
//       ));
//     }
//     return list;
//   }
// }