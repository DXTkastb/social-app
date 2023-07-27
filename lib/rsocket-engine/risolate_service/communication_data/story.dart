class Story {
  final int? storyid;

  /*
	 * image file name is fetched from user device app
	 * image file name convention: accountname:instant_in_seconds.extension
	 */

  final String imgurl;
  final String accountname;
  final int? stime;
  final int ismemory;

  Story(this.storyid, this.imgurl, this.accountname, this.stime, this.ismemory);

  static Story fromDynamicMap(dynamic e) {
    if(e['stime'] == null) {
      return Story(e['storyid'], e['imgurl'], e['accountname'], 0, 0);
    }
    if(e['ismemory'] == null) {
      return Story(e['storyid'], e['imgurl'], e['accountname'], ((((e['stime'] as List)[1]) / 1000000000)).toInt(), 0);
    }
    return Story(e['storyid'], e['imgurl'], e['accountname'],
        ((((e['stime'] as List)[1]) / 1000000000)).toInt(), e['ismemory']);
  }
}
