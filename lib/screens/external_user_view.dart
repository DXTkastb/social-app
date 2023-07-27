import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/component_widgets/ffs_widget.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/communication_lib.dart';

import '../component_widgets/general_profile_image.dart';
import '../component_widgets/grid_box.dart';
import '/component_widgets/follow_button.dart';
import '/component_widgets/story_box.dart';
import '/configs/ScrollConfig.dart';
import '/data/models/external_user_data_model.dart';
import '/routes/router.dart';
import '/screens/windows/user_screen.dart';
import '../change_notifiers/app_state_notifier.dart';

class ExternalUserView extends StatelessWidget {
  final User user;

  const ExternalUserView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    var appUserProvider = Provider.of<AppStateNotifier>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Provider<ExternalUserDataModel>(
          create: (_) =>
          ExternalUserDataModel(
              user: user, searchAccountName: appUserProvider.user.accountname)
            ..init(),
          dispose: (_, eudm) => eudm.dispose(),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              var provider =
              Provider.of<ExternalUserDataModel>(ctx, listen: false);
              return WillPopScope(
                onWillPop: () async {
                  Navigator.of(context).pop(provider.didChange);
                  return false;
                },
                child: Column(
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
                          SizedBox(
                            width: 70,
                            child: GestureDetector(
                                onTap: () {
                                  Navigator
                                      .of(context)
                                      .pop(provider.didChange);
                                  },
                                child: const Icon(Icons.arrow_back)),
                          ),
                          Expanded(
                              child: Text(
                                user.username!,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              )),
                          const SizedBox(
                            height: 40,
                            width: 70,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: FutureBuilder(
                          future: provider.dataLoadFuture,
                          // Data from accountname
                          builder: (futureContext, snapshot) {
                            Widget widget = const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.deepPurple,
                                ),
                              ),
                            );

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              var userx = provider.user;
                              widget = FutureBuilder(
                                  future: provider.postsLoadFuture,
                                  builder: (futureContext2, snapshot) {
                                    List<Widget> children = GridBox
                                        .loadingListContainer();
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      children = provider.userposts
                                          .map((e) =>
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(futureContext2)
                                                  .pushNamed(
                                                  AppRoutePaths.postViewRoute,
                                                  arguments: [false, e.postid]);
                                            },
                                            child: GridBox.getPostsImages(
                                                'http://192.168.29.136:8080/post-image/${e.imgurl}'),
                                          ))
                                          .toList(growable: false);
                                    }
                                    return CustomScrollView(
                                      key: const Key('custom-scroll'),
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
                                                          color: Colors.white,
                                                          width: 1)),
                                                  color: Colors.white),
                                              padding: const EdgeInsets.only(
                                                  top: 70,
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 4),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                                children: [
                                                  Container(
                                                      alignment: Alignment
                                                          .center,
                                                      height: 60,
                                                      padding:
                                                      const EdgeInsets.all(12),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          const SizedBox(
                                                            width: double
                                                                .infinity,
                                                          ),
                                                          Text(
                                                            user.about ?? "",
                                                            key: const Key(
                                                                'about_data'),
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                color: Color
                                                                    .fromRGBO(
                                                                    46, 34, 73,
                                                                    1.0)),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            user.link ?? "",
                                                            key: const Key(
                                                                'link_data'),
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                color: Color
                                                                    .fromRGBO(
                                                                    111,
                                                                    61,
                                                                    250,
                                                                    1.0)),
                                                          )
                                                        ],
                                                      )),
                                                  Container(
                                                    height: 50,
                                                    padding: const EdgeInsets
                                                        .only(
                                                        top: 4,
                                                        bottom: 10,
                                                        left: 50,
                                                        right: 50),
                                                    child: Table(
                                                      children: [
                                                        TableRow(children: [
                                                          Align(
                                                            alignment:
                                                            Alignment.center,
                                                            child: TableTopText(
                                                                count:
                                                                user
                                                                    .postsCount??0),
                                                          ),
                                                          Align(
                                                            alignment:
                                                            Alignment.center,
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                showModalBottomSheet(
                                                                    elevation: 5,
                                                                    backgroundColor: Colors
                                                                        .white,
                                                                    context: context,
                                                                    builder: (
                                                                        _) =>
                                                                        FfsWidget(
                                                                            type: 1,
                                                                            accountName:
                                                                            user
                                                                                .accountname!));
                                                              },
                                                              child: TableTopText(
                                                                  count: userx
                                                                      .followerCount??0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                            Alignment.center,
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                showModalBottomSheet(
                                                                    context: context,
                                                                    builder: (
                                                                        _) =>
                                                                        FfsWidget(
                                                                            type: 2,
                                                                            accountName:
                                                                            user
                                                                                .accountname!));
                                                              },
                                                              child: TableTopText(
                                                                  count: userx.followingCount??0),
                                                            ),
                                                          ),
                                                        ]),
                                                        const TableRow(
                                                            children: [
                                                              Align(
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                child: TableBottomText(
                                                                    text: 'POSTS'),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                child: TableBottomText(
                                                                    text: 'FOLLOWERS'),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                child: TableBottomText(
                                                                    text: 'FOLLOWING'),
                                                              ),
                                                            ])
                                                      ],
                                                    ),
                                                  ),
                                                  const Divider(
                                                    color: Colors.blueGrey,
                                                    height: 20,
                                                    indent: 10,
                                                    endIndent: 10,
                                                  ),
                                                  const ExternalUserStoryBox()
                                                ],
                                              ),
                                            ),
                                          ),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                      25),
                                                  bottomRight: Radius.circular(
                                                      25))),
                                          title: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                    10),
                                                child: GeneralAccountImage(
                                                  accountName: provider.user
                                                      .accountname!, size: 55,),
                                              ),
                                              Column(
                                                  mainAxisSize: MainAxisSize
                                                      .min,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      userx.username!,
                                                      style: const TextStyle(
                                                          color: Color.fromRGBO(
                                                              32, 16, 52, 1.0)),
                                                    ),
                                                    const SizedBox(
                                                      height: 2,
                                                    ),
                                                    Text(
                                                      user.delegation ?? "",
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Color.fromRGBO(
                                                              67, 59, 89, 1.0)),
                                                    )
                                                  ]),
                                              const Expanded(child: SizedBox()),
                                              // (provider.following)
                                              //     ? const SizedBox()
                                              //     :
                                              const Padding(
                                                padding: EdgeInsets.all(10),
                                                child: FollowButton(),
                                              )
                                            ],
                                          ),
                                          backgroundColor: const Color.fromRGBO(
                                              255, 255, 255, 1.0),
                                          pinned: true,
                                          snap: false,
                                          floating: true,
                                        ),
                                        SliverGrid.count(
                                          key: const Key('sliver-posts-grid'),
                                          mainAxisSpacing: 4,
                                          crossAxisSpacing: 4,
                                          crossAxisCount: 3,
                                          children: children,
                                        )
                                      ],
                                    );
                                  });
                            }

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: widget,
                            );
                          },
                        )),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
