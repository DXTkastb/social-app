import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/change_notifiers/app_state_notifier.dart';

import '../component_widgets/instory_profile_image_widget.dart';
import '../rsocket-engine/risolate_service/communication_data/story.dart';
import '/change_notifiers/story_view_notifier.dart';


class StoryViewScreen extends StatelessWidget {
  final List? currentUserStories;
  final String accountname;
  final int? memoryId;
  // final int? instant1;
  // final int? instant2;
  const StoryViewScreen({super.key, required this.accountname,this.currentUserStories, this.memoryId,});

  String timeEpochToString(int time) {
    time = time ~/ 1000000;
    int now = DateTime.now().millisecondsSinceEpoch;
    int diff = DateTime.fromMillisecondsSinceEpoch(now - time).minute;
    if(diff < 60) return  "$diff mn";
    return "${diff~/60} hr";
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        var appStateProvider = Provider.of<AppStateNotifier>(context,listen: false);
        if(memoryId != null) {
          return StoryViewNotifier(accountname)..initWithUserMemories(memoryId!);
        }
        if(currentUserStories != null) {
          return StoryViewNotifier(accountname)..initForCurrentUser((currentUserStories!));
        }
        return StoryViewNotifier(accountname)
          ..init(appStateProvider.user.accountname);
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(193, 172, 229, 1.0),
        body: LayoutBuilder(
          builder: (ctx, constraints) {
            return WillPopScope(
              onWillPop: () async {
              //   Navigator.of(ctx).pop(Provider.of<StoryViewNotifier>(ctx,listen: false).storiesUnseen.isEmpty);
                Navigator.of(ctx).pop();
                return false; },
              child: SafeArea(
                child: Stack(
                  children: [
                    const MainStoryView(),
                    SizedBox(
                      // Container(
                      //    color: Colors.orange,
                      width: constraints.maxWidth,
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 18),
                            width: 50,
                            alignment: Alignment.topCenter,
                            //  color: Colors.green,
                            child: GestureDetector(
                                onTap: () {
                                  // Navigator.of(ctx).pop(Provider.of<StoryViewNotifier>(ctx,listen: false).storiesUnseen.isEmpty);
                                  Navigator.of(ctx).pop();
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.blueGrey,
                                )),
                          ),
                          Expanded(
                              child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(45)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.white,
                                            blurRadius: 7.5,
                                            spreadRadius: 0.2)
                                      ]),
                                  child: InstoryProfileImage(accountName: accountname,),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Text(accountname),
                              ],
                            ),
                          )),
                          Container(
                            padding: const EdgeInsets.only(top: 18),
                            width: 50,
                            alignment: Alignment.topCenter,
                            child: Consumer<StoryViewNotifier>(
                              builder: (_, svn, child) {
                                return FutureBuilder(
                                    future: svn.future,
                                    builder: (_, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        int time = svn.stories[svn.currentIndex].stime!;
                                        return Text(
                                          timeEpochToString(time),
                                          style: const TextStyle(
                                              color: Colors.blueGrey,
                                              fontSize: 17.2),
                                        );
                                      }
                                      return const Text('');
                                    });
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MainStoryView extends StatelessWidget {
  const MainStoryView({super.key});

  Widget getLightBox() {
    return const Expanded(
        child: SizedBox(
            height: 4,
            child: ColoredBox(
              color: Color.fromRGBO(157, 108, 224, 1.0),
            )));
  }

  Widget getDarkBox() {
    return const Expanded(
        child: SizedBox(
            height: 4,
            child: ColoredBox(
              color: Color.fromRGBO(80, 23, 161, 1.0),
            )));
  }

  Widget getLoadingBox(int x) {
    return Expanded(
        child: LinearProgressBar(
      key: ValueKey(x),
    ));
  }

  List<Widget> getChildren(int currentIndex, int maxLength) {
    List<Widget> list = [];

    for (int i = 0; i < maxLength; i++) {
      if (i != 0) {
        list.add(
          const SizedBox(
            width: 3,
          ),
        );
      }

      if (i < currentIndex)
        list.add(getDarkBox());
      else if (i > currentIndex)
        list.add(getLightBox());
      else
        list.add(getLoadingBox(i));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(193, 172, 229, 1.0),
      child: Consumer<StoryViewNotifier>(
        builder: (cvx, svn, child) {
          return FutureBuilder(
              future: svn.future,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Story story = svn.getStoryByIndex(svn.currentIndex);
                  return GestureDetector(
                    onTap: () {
                      if (svn.currentIndex + 1 == svn.stories.length) {
                       //  Navigator.of(ctx).pop(true);
                        Navigator.of(ctx).pop();
                      } else {
                        svn.incrementIndex();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                            //    'https://picsum.photos/id/45/800/1900'
                            'http://192.168.29.136:8080/story-image/${story.imgurl}',
                            ),
                            fit: BoxFit.fill),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                              children: getChildren(
                                  svn.currentIndex, svn.stories.length)),
                        ],
                      ),
                    ),
                  );
                }

                return const Center(
                    child: SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        )));
              });
        },
      ),
    );
  }
}

class LinearProgressBar extends StatefulWidget {
  const LinearProgressBar({super.key});

  @override
  State<LinearProgressBar> createState() => _LinearProgressBarState();
}

class _LinearProgressBarState extends State<LinearProgressBar> {
  late StreamSubscription streamSubscription;
  double current = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var provider = Provider.of<StoryViewNotifier>(context, listen: false);
    streamSubscription =
        Stream.periodic(const Duration(milliseconds: 50), (y) => y)
            .take(100)
            .listen((event) {
      setState(() {
        current = current + 50;
      });
      if (event == 99 && mounted) {
        if (provider.currentIndex + 1 == provider.stories.length) {
          Navigator.of(context).pop(true);
        } else {
          provider.incrementIndex();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: current / 5000,
      color: const Color.fromRGBO(80, 23, 161, 1.0),
      backgroundColor: const Color.fromRGBO(157, 108, 224, 1.0),
    );
  }
}
