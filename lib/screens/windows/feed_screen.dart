import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/change_notifiers/app_state_notifier.dart';
import 'package:socio/component_widgets/normal_circular_indicator.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/communication_lib.dart';
import 'package:socio/support_logic/support_functions.dart';

import '/change_notifiers/timeline_posts_set_notifier.dart';
import '/component_widgets/bottom_buttons.dart';
import '/component_widgets/likes_bootom_sheet.dart';

import '/routes/router.dart';
import '../../component_widgets/general_profile_image.dart';
import '../../rsocket-engine/risolate_service/main_isolate_engine.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<TimelinePostsNotifier>(context, listen: false);
    return FutureBuilder(
        future: provider.getTimelinePostsFuture,
        builder: (futureContext, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Expanded(child: Consumer<TimelinePostsNotifier>(
                      builder: (consumerContext, tpn, child) {

                        if(tpn.posts.isEmpty) return const Center(child: Text('No Posts Available'),);

                        List<TimelinePost> list = tpn.posts;
                        return NotificationListener<ScrollEndNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.extentAfter <= 400 &&
                                tpn.canLoadMore) {
                              tpn.loadMore();
                              return true;
                            }
                            return false;
                          },
                          child: ListView.builder(
                              controller: tpn.scrollController,
                              key: const PageStorageKey<String>(
                                  'timeline-feeds-list'),
                              physics: const BouncingScrollPhysics(),
                              prototypeItem: const Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                margin: EdgeInsets.only(
                                    left: 11, right: 11, bottom: 5, top: 5),
                                child: SizedBox(
                                  height: 480,
                                ),
                              ),
                              padding:
                                  const EdgeInsets.only(bottom: 80, top: 55),
                              itemCount: (tpn.canLoadMore)
                                  ? (list.length + 1)
                                  : list.length,
                              itemBuilder: (ctx, index) {
                                if (index == list.length) {
                                  return const Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    margin: EdgeInsets.only(
                                        left: 11, right: 11, bottom: 5, top: 5),
                                    child: SizedBox(
                                      height: 480,
                                      child: Center(
                                        child: NormalCircularIndicator(),
                                      ),
                                    ),
                                  );
                                }
                                return TimelinePostCard(
                                    timelinePost: list[list.length -1 -index]);
                              }),
                        );
                      },
                    ))
                  ],
                ),
                const Positioned(top: 85, child: LoadMoreFeedsWidget())
              ],
            );
          }

          return const Center(
            child: NormalCircularIndicator(),
          );
        });
  }
}

class LoadMoreFeedsWidget extends StatefulWidget {
  const LoadMoreFeedsWidget({super.key});

  @override
  State<LoadMoreFeedsWidget> createState() => _LoadMoreFeedsWidgetState();
}

class _LoadMoreFeedsWidgetState extends State<LoadMoreFeedsWidget> {
  late TimelinePostsNotifier provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = Provider.of<TimelinePostsNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: provider.updateStream,
        builder: (ctx, snapshot) {
          return AnimatedCrossFade(
              sizeCurve: Curves.easeIn,
              key: const Key('new-feeds-load'),
              firstChild: TaskPurpleButtonWithIcon(
                onpressed: () {
                  provider.scrollController.jumpTo(
                      // provider.scrollController.position.minScrollExtent
                      0.0);
                  provider.updateFeedsList();
                  setState(() {});
                },
                buttonWidget: const Text('new posts'),
                color: Colors.black,
                iconData: Icons.expand_more,
              ),
              secondChild: const SizedBox(),
              crossFadeState: (provider.newPostsLoaded.isNotEmpty)
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 350));
        });
  }
}

class TimelinePostCard extends StatefulWidget {
  final TimelinePost timelinePost;

  const TimelinePostCard({super.key, required this.timelinePost});

  @override
  State<TimelinePostCard> createState() => _TimelinePostCardState();
}

class _TimelinePostCardState extends State<TimelinePostCard> {

  void updateLike() {
    var provider = Provider.of<AppStateNotifier>(context, listen: false);
    setState(() {
      if (widget.timelinePost.liked) {
        widget.timelinePost.like();
      } else {
        widget.timelinePost.unlike();
      }
      widget.timelinePost.liked = !widget.timelinePost.liked;
    });
    MainIsolateEngine.engine.sendMessage({
      'operation': (widget.timelinePost.liked) ? 'POST_LIKE' : 'POST_DISLIKE',
      'data': {
        'accountName': provider.user.accountname,
        'onpostid': widget.timelinePost.postid,
        'postCreatorName': widget.timelinePost.accountname
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      margin: const EdgeInsets.only(left: 11, right: 11, bottom: 5, top: 5),
      color: const Color.fromRGBO(239, 229, 255, 1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 2),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          AppRoutePaths.externalUserViewRoute,
                          arguments: widget.timelinePost.accountname);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GeneralAccountImage(
                          accountName: widget.timelinePost.accountname,
                          size: 45,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.timelinePost.accountname,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: ColoredBox(
                    color: const Color.fromRGBO(47, 39, 58, 1.0),
                    child: Image.network(
                       'http://192.168.29.136:8080/post-image/${widget.timelinePost.imgurl}',
                      fit: BoxFit.contain,
                      errorBuilder: (_,obj,trace) {
                        return const Icon(Icons.image_rounded,color: Colors.deepPurple,);
                      } ,
                    ),
                  )),
              SizedBox(
                height: 45,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: () {
                            updateLike();
                          },
                          child: Icon(
                            (widget.timelinePost.liked)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.deepPurple,
                            size: 28,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              AppRoutePaths.postViewRoute,
                              arguments: [true, widget.timelinePost.postid]);
                        },
                        child: const Icon(
                          Icons.comment,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 2,
              ),
              SizedBox(
                height: 73,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                  enableDrag: false,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(24),
                                          topLeft: Radius.circular(24))),
                                  backgroundColor: Colors.white,
                                  context: context,
                                  builder: (_) {
                                    return PostsLikeBottomSheet(id: widget.timelinePost.postid);
                                  });
                            },
                            child: Text(
                              (widget.timelinePost.likesCount > 0)
                                  ? 'liked by ${Support.value.format(widget.timelinePost.likesCount)} people'
                                  : 'be the first to like',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            AppRoutePaths.postViewRoute,
                            arguments: [false, widget.timelinePost.postid]).then((value) {
                              if(context.mounted){
                                if(value!=null && value as bool){
                                  // post is deleted

                                }
                              }
                        });
                      },
                      child: Container(
                          padding: const EdgeInsets.only(
                              bottom: 10, top: 8, left: 12, right: 12),
                          height: 53,
                          alignment: Alignment.topLeft,
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(
                                    text: '${widget.timelinePost.accountname} ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                                TextSpan(
                                    text: widget.timelinePost.caption,
                                    style: const TextStyle(
                                        color: Color.fromRGBO(61, 61, 61, 1.0),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11.4)),
                              ],
                            ),
                          )),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
