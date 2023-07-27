import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/component_widgets/general_profile_image.dart';
import '../../component_widgets/ffs_widget.dart';
import '/change_notifiers/app_state_notifier.dart';
import '/change_notifiers/user_metadata_notifier.dart';
import '/change_notifiers/user_personal_posts_set_notifier.dart';
import '/component_widgets/story_box.dart';
import '/configs/ScrollConfig.dart';
import '/routes/router.dart';
import '/change_notifiers/user_data_notifier.dart';
import '/component_widgets/grid_box.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({
    super.key,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    var appStateProvider = Provider.of<AppStateNotifier>(context, listen: false);
    return LayoutBuilder(builder: (ctx, constraints) {
      var userPersonalPostSetProvider =
          Provider.of<UserPersonalPostSet>(ctx, listen: false);
      return Column(
        children: [
          Container(
            width: constraints.maxWidth,
            height: 80,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(174, 138, 255, 1.0),
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 50,
                ),
                Expanded(
                    child: Text(
                      appStateProvider
                      .user!
                      .accountname,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )),
                SizedBox(
                  height: 40,
                  width: 30,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(AppRoutePaths.settingRoute);
                    },
                    child: const Icon(
                      Icons.menu_sharp,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          Expanded(
              child: FutureBuilder(
            future: userPersonalPostSetProvider.fetchUserPosts,
            // PostsProvider Future
            builder: (futureContext, snapshot) {
              List<Widget> list = GridBox.loadingListContainer();
              if (snapshot.connectionState == ConnectionState.done) {
                list = userPersonalPostSetProvider.userposts
                    .map((e) => GestureDetector(
                  onTap: (){
                    Navigator.of(futureContext).pushNamed(AppRoutePaths.postViewRoute,arguments: [false,e.postid]);
                  },
                  child: GridBox.getPostsImages(
                      'http://192.168.29.136:8080/post-image/${e.imgurl}'
                      ),))
                    .toList(growable: false);
              }
              return CustomScrollView(
                key: const Key('user-screen-data-scroll-view'),
                //   physics: const  BouncingScrollPhysics(),
                scrollBehavior: ScrollConfig(),
                slivers: [
                  SliverAppBar(
                    key: const Key('user-screen-app-bar'),
                    titleSpacing: 10,
                    leadingWidth: 0,
                    toolbarHeight: 90,
                    expandedHeight: 280,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: null,
                      background: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.transparent, width: 1)),
                        ),
                        padding: const EdgeInsets.only(
                            top: 70, left: 10, right: 10, bottom: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                                alignment: Alignment.center,
                                height: 60,
                                padding: const EdgeInsets.all(12),
                                child: Consumer<UserDataNotifier>(
                                  builder: (_, udn, wid) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: double.infinity,
                                        ),
                                        Text(
                                          udn.about??"",
                                          key: const Key('about_data'),
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Color.fromRGBO(
                                                  46, 34, 73, 1.0)),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          udn.link??"",
                                          key: const Key('link_data'),
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Color.fromRGBO(
                                                  111, 61, 250, 1.0)),
                                        )
                                      ],
                                    );
                                  },
                                )),
                            Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                  top: 4, bottom: 10, left: 50, right: 50),
                              child: Consumer<UserMetaDataNotifier>(
                                builder: (_, umdn, wid) {
                                  return Table(
                                    children: [
                                      TableRow(children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: TableTopText(
                                              count: umdn.postsCount),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: GestureDetector(
                                            onTap:(){
                                              showModalBottomSheet(
                                                  elevation: 5,
                                                  backgroundColor: Colors.white,
                                                  context: context,
                                                  builder: (_) =>
                                                      FfsWidget(
                                                          type: 1,
                                                          accountName:
                                                          appStateProvider.user!.accountname));
                                            },
                                            child: TableTopText(
                                                count: umdn.followerCount),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: GestureDetector(
                                            onTap:(){
                                              showModalBottomSheet(
                                                  elevation: 5,
                                                  backgroundColor: Colors.white,
                                                  context: context,
                                                  builder: (_) =>
                                                      FfsWidget(
                                                          type: 2,
                                                          accountName:
                                                          appStateProvider.user!.accountname));
                                            },
                                            child: TableTopText(
                                                count: umdn.followingCount),
                                          ),
                                        ),
                                      ]),
                                      const TableRow(children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: TableBottomText(text: 'POSTS'),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: TableBottomText(
                                              text: 'FOLLOWERS'),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: TableBottomText(
                                              text: 'FOLLOWING'),
                                        ),
                                      ])
                                    ],
                                  );
                                },
                              ),
                            ),
                            const Divider(
                              color: Colors.blueGrey,
                              height: 20,
                              indent: 10,
                              endIndent: 10,
                            ),
                            const UserStoryBox()
                          ],
                        ),
                      ),
                    ),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25))),
                    title: Consumer<UserDataNotifier>(
                      builder: (_, udn, wid) {
                        return ColoredBox(
                          key: const Key('sliver_main_titlebar'),
                          color: const Color.fromRGBO(193, 172, 229, 1.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: GeneralAccountImage(accountName: appStateProvider.user
                                    .accountname,size: 55,),
                              ),
                              Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      udn.username,
                                      style: const TextStyle(
                                          color:
                                              Color.fromRGBO(32, 16, 52, 1.0)),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      udn.delegation??"",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color:
                                              Color.fromRGBO(67, 59, 89, 1.0)),
                                    )
                                  ]),
                            ],
                          ),
                        );
                      },
                    ),
                    backgroundColor: const Color.fromRGBO(193, 172, 229, 1.0),
                    pinned: true,
                    snap: false,
                    floating: true,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 85),
                    sliver: SliverGrid.count(
                      key: const Key('posts-sliver-grid'),
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      crossAxisCount: 3,
                      children: list,
                    ),
                  ),
                ],
              );
            },
          ))
        ],
      );
    });
  }
}

class TableTopText extends StatelessWidget {
  final int count;

  const TableTopText({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count',
      style: const TextStyle(
          fontSize: 23, color: Colors.black, fontWeight: FontWeight.w900),
    );
  }
}

class TableBottomText extends StatelessWidget {
  final String text;

  const TableBottomText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: Color.fromRGBO(104, 95, 145, 1.0)),
    );
  }
}
