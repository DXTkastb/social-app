class User {
  late String username;
  late String accountname;
  late String? profileurl;
  late String? delegation;
  late String? about;
  late String? link;
  late int postsCount;
  late int followerCount;
  late int followingCount;

  User({
    required this.username,
    required this.accountname,
    required this.profileurl,
    required this.delegation,
    required this.about,
    required this.link,
    required this.postsCount,
    required this.followerCount,
    required this.followingCount,
  });


  static final User _defaultUser = User(
      username: '',
      accountname: '',
      profileurl: '',
      delegation: '',
      about: '',
      link: '',
      postsCount: 0,
      followerCount: 0,
      followingCount:0);

  static final User _defaultExternalUser = User(
      username: 'Artic Monkey',
      accountname: 'Chimps',
      profileurl: 'dxtk.jpg',
      delegation: 'Musician',
      about: 'Let the drums roll',
      link: 'www.music.com',
      postsCount: 544,
      followerCount: 7134,
      followingCount: 91);

  static User newUser(Map map) {
    return User(
        username: map['username'],
        accountname: map['accountname'],
        profileurl: map['piurl'],
        delegation: map['delegation'],
        about: map['about'],
        link: map['link'],
        postsCount: map['postsCount'],
        followerCount: map['followerCount'],
        followingCount: map['followingCount']);
  }

  static User getNullUser() {
    return _defaultUser;
  }

  static User getExternalUser() {
    return _defaultExternalUser;
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
}
