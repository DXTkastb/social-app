import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:socio/component_widgets/general_profile_image.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/like.dart';

import '../rsocket-engine/risolate_service/main_isolate_engine.dart';
import 'loda_more_list_widget.dart';

class PostsLikeBottomSheet extends StatefulWidget {
  final int id;

  const PostsLikeBottomSheet({super.key, required this.id});

  @override
  State<PostsLikeBottomSheet> createState() => _PostsLikeBottomSheetState();
}

class _PostsLikeBottomSheetState extends State<PostsLikeBottomSheet> {
  ScrollController scrollController = ScrollController();
  bool loadingOldLikes = false;
  bool canLoadMore = true;
  List<Like> likesList = [];
  late Future loadLikes;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadLikes = loadLikesList(true);
  }

  Future loadLikesList(bool initialLoad) async {
    if (!canLoadMore && loadingOldLikes) return;
    loadingOldLikes = true;
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_LIKES',
      'data': {
        'postid': widget.id,
        'lastFetchId': (initialLoad) ? null : likesList.last.id
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if (list.isEmpty) {

    } else {
      if (mounted) {
        List<Like> newLoadedLikes = list[0];
        likesList.addAll(newLoadedLikes);
        loadingOldLikes = false;
        if (newLoadedLikes.length < 50) canLoadMore = false;
        if (!initialLoad) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: const [
                  Icon(
                    Icons.favorite,
                    color: Colors.deepPurple,
                    size: 28,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'likes',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                  )
                ],
              ),
            ),
          ),
          Expanded(
              child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (val) {
              val.disallowIndicator();
              return false;
            },
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 30 && canLoadMore) {
                  loadLikesList(false);
                }
                return true;
              },
              child: FutureBuilder(
                future: loadLikes,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    int size = 0;
                    if (canLoadMore)
                      size = likesList.length + 1;
                    else
                      size = likesList.length;

                    if (size == 0) {
                      return const Center(
                        child: Text('No likes'),
                      );
                    }

                    return ListView.builder(
                        controller: scrollController,
                        prototypeItem: const SizedBox(
                          height: 50,
                        ),
                        padding: const EdgeInsets.only(left: 18, right: 18),
                        itemCount: size,
                        itemBuilder: (_, index) {
                          Widget widget;
                          if (index == likesList.length) {
                            widget = const LoadMoreWidgetList();
                          } else {
                            widget = GestureDetector(
                                onTap: () {
                                  // push to external user view
                                },
                                child: Row(
                                  children: [
                                    GeneralAccountImage(
                                        accountName:
                                            likesList[index].accountname,
                                        size: 40),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Text(
                                      likesList[index].accountname,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ));
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              height: 40,
                              child: widget,
                            ),
                          );
                        });
                  }
                  return const Center(
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    ),
                  );
                },
              ),
            ),
          ))
        ],
      ),
    );
  }
}
