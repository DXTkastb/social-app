import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/component_widgets/circular_story_image_widget.dart';

import '../change_notifiers/new_follower_story_set_notifier.dart';
import '../rsocket-engine/risolate_service/communication_data/follower_story.dart';
import '/change_notifiers/app_state_notifier.dart';
import '/change_notifiers/follower_story_set_notifier.dart';
import '/change_notifiers/user_personal_story.dart';
import '/routes/router.dart';

class TopStoriesContainer extends StatelessWidget {
  const TopStoriesContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 13, right: 13),
      decoration: const BoxDecoration(
          color: Color.fromRGBO(174, 138, 255, 1.0),
          borderRadius: BorderRadius.all(Radius.circular(45))),
      child: const TopStoriesBar(),
    );
  }
}

class TopStoriesBar extends StatelessWidget {
  const TopStoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    String acname =
        Provider.of<AppStateNotifier>(context, listen: false).user.accountname;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer<UserPersonalStoryNotifier>(
          builder: (ctx, upsn, widget) {
            return FutureBuilder(
              builder: (futureContext, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: (upsn.currentStories.isNotEmpty)
                                ? const Color.fromRGBO(118, 12, 255, 1.0)
                                : Colors.black,
                            width: 2),
                        borderRadius: BorderRadius.circular(50)),
                    child: GestureDetector(
                        onTap: () {
                          if(upsn.currentStories.isNotEmpty) {
                            Navigator.of(futureContext).pushNamed(
                              AppRoutePaths.storyViewRoute,
                              arguments: [acname,upsn.currentStories,null]);
                          }
                        },
                        child: widget),
                  );
                }
                return AnimatedContainer(
                  duration: const Duration(seconds: 3),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12, width: 2),
                      borderRadius: BorderRadius.circular(50)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      widget!,
                      const SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(184, 120, 252, 0.5),
                        ),
                      )
                    ],
                  ),
                );
              },
              future: upsn.fetchCurrentStoryFuture,
            );
          },
          child: StoryImageWidget(accountName: acname),
        ),
        const VerticalDivider(
          color: Colors.black,
          width: 15,
          thickness: 1,
          indent: 8,
          endIndent: 8,
        ),
        Expanded(
            child: ChangeNotifierProvider<NewFollowerStoriesSet>(
          create: (notifierContext) => NewFollowerStoriesSet()..init(acname),
          builder: (notifierContext, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(55),
              child: Consumer<NewFollowerStoriesSet>(
                builder: (consumerContext, fss, widget) {
                  return FutureBuilder(
                      future: fss.futureFetchStories,
                      builder: (_, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return ListView.separated(
                              key: const Key('follower-story-list'),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, index) {
                                String acname= fss.accountNames[index];
                               // NEED TO WORK HERE, story passed shouldn't be null!
                                return StoryAvatar(
                                  accountName: acname,);
                              },
                              separatorBuilder: (_, index) =>
                                  const VerticalDivider(
                                    color: Colors.transparent,
                                    width: 8,
                                  ),
                              itemCount: fss.accountNames.length);
                        }

                        return ListView.separated(
                            key: const Key('follower-story-list'),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, index) {
                              return const StoryAvatar(accountName:'',);
                            },
                            separatorBuilder: (_, index) =>
                                const VerticalDivider(
                                  color: Colors.transparent,
                                  width: 8,
                                ),
                            itemCount: 5);
                      });
                },
              ),
            );
          },
        )),
      ],
    );
  }
}

class StoryAvatar extends StatefulWidget {
  final String accountName;
 // final FollowerStory? story;

  const StoryAvatar({super.key,  required this.accountName});

  @override
  State<StoryAvatar> createState() => _StoryAvatarState();
}

class _StoryAvatarState extends State<StoryAvatar> {
  @override
  Widget build(BuildContext context) {
    // if (widget.story == null) {
    //   return GestureDetector(
    //     onTap: null,
    //     child: Container(
    //       padding: const EdgeInsets.all(2),
    //       decoration: BoxDecoration(
    //           border: Border.all(
    //               width: 2, color: const Color.fromRGBO(68, 68, 68, 1.0)),
    //           borderRadius: BorderRadius.circular(50)),
    //       child: const ClipRRect(
    //         borderRadius: BorderRadius.all(Radius.circular(45)),
    //         child: SizedBox(
    //           width: 50,
    //           height: 50,
    //         ),
    //       ),
    //     ),
    //   );
    // }
    if(widget.accountName.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            border: Border.all(
                width: 2,
                color: const Color.fromRGBO(118, 12, 255, 1.0)),
            borderRadius: BorderRadius.circular(50)),
        child: const LoadingStoryImageWidget(),
      );
    }
    var provider = Provider.of<NewFollowerStoriesSet>(context, listen: false);
    return GestureDetector(
      onTap: () async {
        provider.pauseStream();
        await Navigator.of(context).pushNamed(
            AppRoutePaths.storyViewRoute,
            arguments: [widget.accountName,null,null]);
        // bool allViewed = await Navigator.of(context).pushNamed(
        //     AppRoutePaths.storyViewRoute,
        //     arguments: [widget.accountName,null]) as bool;
        // if (mounted && (widget.story!.viewedAll || allViewed)) {
        //   setState(() {
        //     widget.story!.setViewedAll();
        //   });
        //   provider.resumeStream();
        // }
        if(mounted) provider.resumeStream();
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            border: Border.all(
                width: 2,
                color: const Color.fromRGBO(118, 12, 255, 1.0)),
            borderRadius: BorderRadius.circular(50)),
        child: StoryImageWidget(
          accountName: widget.accountName,
        ),
      ),
    );
  }
}
