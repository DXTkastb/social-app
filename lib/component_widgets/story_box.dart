import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/component_widgets/general_profile_image.dart';
import 'package:socio/routes/router.dart';
import '../rsocket-engine/risolate_service/communication_data/story.dart';
import '/change_notifiers/user_metadata_notifier.dart';
import '/data/models/external_user_data_model.dart';

class UserStoryBox extends StatelessWidget {
  const UserStoryBox({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<UserMetaDataNotifier>(context, listen: false);
    return Container(
      // color: Colors.red,
      height: 55,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 10),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowIndicator();
          return false;
        },
        child: FutureBuilder(
          future: provider.getMemoriesFuture, // StoryProvider Future
          builder:
              (BuildContext futureContext, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: provider.memoryStories.length,
                itemBuilder: (_, index) {
                  return
                  MemoryWidgetFactory(story:provider.memoryStories[index]);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const VerticalDivider(
                    color: Colors.transparent,
                    width: 10,
                    indent: 10,
                    endIndent: 10,
                  );
                },
              );
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (_, index) {
                return Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(34, 25, 54, 1.0),
                      //color: const Color.fromRGBO(22, 0, 58, 1.0),
                      borderRadius: BorderRadius.circular(30)),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const VerticalDivider(
                  color: Colors.transparent,
                  width: 10,
                  indent: 10,
                  endIndent: 10,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ExternalUserStoryBox extends StatelessWidget {
  const ExternalUserStoryBox({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ExternalUserDataModel>(context, listen: false);
    return Container(
      // color: Colors.red,
      height: 55,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 10),

      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowIndicator();
          return false;
        },
        child: FutureBuilder(
          future: provider.memoriesLoadFuture, // StoryProvider Future
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                key: const Key('grouped-stories'),
                scrollDirection: Axis.horizontal,
                itemCount: provider.storyMemories.length,
                itemBuilder: (_, index) {
                  return MemoryWidgetFactory(story: provider.storyMemories[index],);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const VerticalDivider(
                    color: Colors.transparent,
                    width: 8,
                  );
                },
              );
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              key: const Key('grouped-stories'),
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (_, index) {
                return Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(34, 25, 54, 1.0),
                      //color: const Color.fromRGBO(22, 0, 58, 1.0),
                      borderRadius: BorderRadius.circular(30)),
                  child: null,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const VerticalDivider(
                  color: Colors.transparent,
                  width: 10,
                  indent: 10,
                  endIndent: 10,
                );
              },
            );
          },
        ),
      ),
    );
  }
}


class MemoryWidgetFactory extends StatelessWidget{
  final Story story;
  const MemoryWidgetFactory({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed(AppRoutePaths.storyViewRoute,arguments: [story.accountname,null,story.ismemory]);
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: Colors.deepPurple, width: 1)),
        padding: const EdgeInsets.all(2),
        child: GeneralAccountImage(accountName: story.accountname!, size: 49,fromResource: story.imgurl,),
      ),
    );
  }

}