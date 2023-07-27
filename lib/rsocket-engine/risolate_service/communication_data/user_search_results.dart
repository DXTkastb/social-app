
class UserSearchResults {
  final int queryNumber;
  late final List<User> data;

  UserSearchResults({required Object listOfUsers,required this.queryNumber}) {
    listOfUsers = listOfUsers as List;
    data = listOfUsers.map((e) {
      e = e! as Map;
      return User.fromSearch(
          accountname: e['acname'], username: e['uname'], profileurl: e['pi-url']);
    }).toList(growable: false);
  }
}

class User {
  String? username;
  String? accountname;
  String? profileurl;
  String? delegation;
  String? about;
  String? link;
  int? postsCount;
  int? followerCount;
  int? followingCount;
  bool follow = false;

  User.fromSearch(
      {required this.accountname, required this.username, required this.profileurl});

  User.fromExternalFetch({required Object userData}) {
    userData = userData as Map;
    username = userData['username'];
    accountname = userData['accountname'];
    profileurl = userData['profileurl'];
    delegation = userData['delegation'];
    about = userData['about'];
    link = userData['link'];
    postsCount = userData['postsCount'];
    followerCount = userData['followerCount'];
    followingCount = userData['followingCount'];
    follow = userData['follow'];
  }

  User.fromMetaData({required Object userData}) {
    userData = userData as Map;
    username = userData['username'];
    accountname = userData['accountname'];
    profileurl = userData['profileurl'];
    delegation = userData['delegation'];
    about = userData['about'];
    link = userData['link'];
    postsCount = userData['postsCount'];
    followerCount = userData['followerCount'];
    followingCount = userData['followingCount'];
  }

  @override
  String toString() {
    return 'User{username: $username, accountname: $accountname, profileurl: $profileurl, delegation: $delegation, about: $about, link: $link, postsCount: $postsCount, followerCount: $followerCount, followingCount: $followingCount, follow: $follow}';
  }
}
