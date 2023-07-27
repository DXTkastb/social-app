import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/change_notifiers/user_data_notifier.dart';
import 'package:socio/component_widgets/bottom_buttons.dart';
import 'package:socio/physics_styles/app_styles.dart';

import '../change_notifiers/user_metadata_notifier.dart';
import '/change_notifiers/app_state_notifier.dart';
import '/change_notifiers/post_comments_notifier.dart';
import '/component_widgets/add_comment_bottom_sheet.dart';
import '/component_widgets/comment_widget.dart';
import '/component_widgets/likes_bootom_sheet.dart';
import '/rsocket-engine/risolate_service/communication_data/communication_lib.dart';
import '/support_logic/support_functions.dart';
import '../change_notifiers/timeline_posts_set_notifier.dart';
import '../change_notifiers/user_personal_posts_set_notifier.dart';
import '../component_widgets/button_circular_indicator.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class PostViewScreen extends StatefulWidget {
  final bool fromComment;
  final int postid;

  const PostViewScreen(
      {super.key, required this.fromComment, required this.postid});

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  late final Future<Post> getPost;

  @override
  void initState() {
    getPost = fetchPostFromBackend();
  }

  Future<Post> fetchPostFromBackend() async {
    ReceivePort port = ReceivePort();
    MainIsolateEngine.engine.sendMessage({
      'operation': 'FETCH_USER_POST',
      'data': {'postid': widget.postid},
      'temp_port': port.sendPort
    });
    var data = ((await port.first) as List).first as Post;
    port.close();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Post>(
      future: getPost,
      builder: (ftContext, snapshot) {
        if (snapshot.hasError) {
          return Container(
            color: const Color.fromRGBO(239, 229, 255, 1.0),
            child: const Text(
              'some error occurred. please try later',
              style: AppStyles.loadErrorTextStyle,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ChangeNotifierProvider<PostCommentsNotifier>(
          create: (_) =>
              PostCommentsNotifier()..init(snapshot.data!, widget.fromComment),
          builder: (notifierContext, wid) {
            return PostViewSubScreen(
              fromComment: widget.fromComment,
              post: snapshot.data! as TimelinePost,
            );
          },
        );
      },
    );
  }
}

class PostViewSubScreen extends StatefulWidget {
  final bool fromComment;
  final TimelinePost post;

  const PostViewSubScreen(
      {super.key, required this.fromComment, required this.post});

  @override
  State<PostViewSubScreen> createState() => _PostViewSubScreenState();
}

class _PostViewSubScreenState extends State<PostViewSubScreen> {

  void showAddCommentBottomSheet() async {
    var accountName =
        Provider.of<AppStateNotifier>(context, listen: false).user.accountname;
    List? data = ((await showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
        )),
        context: context,
        builder: (_) {
          return AddCommentSheet(
            accountname: accountName,
            postCreatorName: widget.post.accountname,
            postid: widget.post.postid,
          );
        })) as List?);
    if (data == null) return;
    String newComment = data[0];
    Future future = data[1];
    if (mounted) {
      String accountName = Provider.of<AppStateNotifier>(context, listen: false)
          .user.accountname;
      Provider.of<PostCommentsNotifier>(context, listen: false)
          .addComment(newComment, accountName, widget.post.postid, future);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.fromComment && mounted) {
      Future.delayed(Duration.zero, () {
        showAddCommentBottomSheet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appUserProvider = Provider.of<AppStateNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
                height: 310,
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.black,
                      width: double.infinity,
                      child: Image.network(
                        'http://192.168.29.136:8080/post-image/${widget.post.imgurl}',
                        errorBuilder: (ctx,obj,trace) {
                          return const Icon(Icons.image_rounded,color: Colors.deepPurple,);
                        },
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                        left: 12,
                        top: 13,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(Icons.arrow_back),
                        ))
                  ],
                )),
            ColoredBox(
                color: const Color.fromRGBO(239, 229, 255, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
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
                                return PostsLikeBottomSheet(id: widget.post.postid);
                              });
                        },
                        child: Text(
                          (widget.post.likesCount > 0)
                              ? 'liked by ${Support.value.format(widget.post.likesCount)} people'
                              : '0 likes',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    (widget.post.accountname.compareTo(appUserProvider.user.accountname) == 0)
                        ? GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (dialogCtx) {
                                    return DeletePostAlertBox(
                                      postid: widget.post.postid,
                                    );
                                  }).then((value) {
                                if (value == null) return;
                                value = value as List;
                                if (mounted) {
                                  if (value[0]) {
                                    Navigator.of(context).pop(true);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(value[1])));
                                  }
                                }
                              });
                            },
                            child: const Padding(
                                padding: EdgeInsets.only(right: 15, top: 10),
                                child: Icon(
                                  Icons.delete_rounded,
                                  size: 20,
                                  color: Colors.black45,
                                )),
                          )
                        : const SizedBox(),
                  ],
                )),
            Container(
                padding: const EdgeInsets.only(
                    bottom: 18, top: 4, left: 15, right: 15),
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(239, 229, 255, 1.0),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15))),
                alignment: Alignment.topLeft,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: '${widget.post.accountname} ',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: widget.post.caption,
                          style: const TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 12)),
                    ],
                  ),
                )),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 17, top: 15, bottom: 12, right: 17),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'comments',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                        onTap: showAddCommentBottomSheet,
                        child: const Icon(
                          Icons.add_box,
                          size: 27,
                          color: Colors.deepPurple,
                        ))
                  ],
                ),
              ),
            ),
            const Expanded(child: CommentListWidget())
          ],
        ),
      ),
    );
  }
}

class CommentListWidget extends StatelessWidget {
  const CommentListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Consumer<PostCommentsNotifier>(
        builder: (consumerContext, pcn, _) {
          return NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter <= 40 && pcn.canLoadMore) {
                pcn.loadMoreComments();
                return true;
              }
              return false;
            },
            child: FutureBuilder(
              future: pcn.getCommentsFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List commentList = pcn.commentsList;
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                        bottom: 5, left: 20, right: 20, top: 0),
                    itemCount: (pcn.canLoadMore)
                        ? (commentList.length + 1)
                        : (commentList.length),
                    itemBuilder: (ctx, index) {
                      if (index == commentList.length) {
                        return const SizedBox(
                            height: 50,
                            child: Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.deepPurple,
                                  )),
                            ));
                      }

                      var comment = pcn.commentsList[index];
                      if (comment.userAddProgress == null) {
                        return UserCommentWidget(
                          comment: comment,
                        );
                      }
                      return UserAddedCommentWidget(comment: comment);
                    },
                  );
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
          );
        },
      ),
    );
  }
}

class DeletePostAlertBox extends StatefulWidget {
  final int postid;

  const DeletePostAlertBox({super.key, required this.postid});

  @override
  State<DeletePostAlertBox> createState() => _DeletePostAlertBoxState();
}

class _DeletePostAlertBoxState extends State<DeletePostAlertBox> {
  bool inProcess = false;
  bool postDeleted = false;

  void deletePost() async {
    if (inProcess || postDeleted) return;

    setState(() {
      inProcess = true;
    });

    var port = ReceivePort();
    var output = port.first.timeout(const Duration(seconds: 5), onTimeout: () {
      return [200];
    });
    String accountName =Provider.of<UserPersonalPostSet>(context, listen: false).accountName;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'DELETE_USER_POST',
      'data': {
        'accountName' : accountName,
        'postId': widget.postid,
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if (list.isEmpty) {
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context)
                .pop([false, 'Connection Interrupted.Please try later']);
          }
        });
      }
    } else {
      var x = list[0] as int;
      if (x == 201) {
        // deletion success;
        if (mounted) {
          Provider.of<UserPersonalPostSet>(context, listen: false)
              .deletePost(widget.postid);
          Provider.of<TimelinePostsNotifier>(context, listen: false)
              .postDeleted(widget.postid);
          Provider.of<UserMetaDataNotifier>(context, listen: false)
              .refreshMetaData();
          setState(() {
            inProcess = false;
            postDeleted = true;
          });
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop([true]);
            }
          });
        }
      } else {
        if (mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context)
                  .pop([false, 'Some error occurred.Please try later']);
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        actionsAlignment: MainAxisAlignment.center,
        icon: const Icon(
          Icons.delete_rounded,
          size: 25,
          color: Color.fromRGBO(194, 81, 96, 1.0),
        ),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TaskPurpleButton(
              onpressed: () {
                if (inProcess || postDeleted) return;
                Navigator.of(context).pop();
              },
              buttonWidget: const Text('cancel'),
              color: Colors.black45),
          (inProcess)
              ? TaskPurpleButton(
                  onpressed: () {},
                  buttonWidget: const SizedBox(
                    height: 15,
                    width: 15,
                    child: ButtonCircularIndicator(),
                  ),
                  color: Colors.red)
              : TaskPurpleButton(
                  onpressed: () {
                    deletePost();
                  },
                  buttonWidget: (postDeleted)
                      ? const Text('deleted')
                      : const Text('delete'),
                  color: (postDeleted)
                      ? const Color.fromRGBO(89, 29, 29, 1.0)
                      : Colors.red),
        ],
      ),
    );
  }
}
