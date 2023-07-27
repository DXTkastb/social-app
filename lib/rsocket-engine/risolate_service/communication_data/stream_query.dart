
class StreamQuery {
  final String accountName;
  final String offset;
  StreamQuery(this.accountName, this.offset);
  static StreamQuery getDummy(String name,String offs){
    return StreamQuery(name, offs);
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map = {};
    map['accountName']= accountName;
    map['offset'] = offset;
    return map;
  }

}