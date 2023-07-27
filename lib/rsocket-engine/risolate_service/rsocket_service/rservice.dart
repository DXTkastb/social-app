import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cbor/simple.dart';
import 'package:socio/rsocket-engine/risolate_service/lib/core/rsocket_requester.dart';

import '../communication_data/ui_notification.dart';
import '../lib/payload.dart';
import '../lib/rsocket.dart';
import '../lib/rsocket_connector.dart';
import 'main_rservice.dart';

class RService {
  late RSocket rsocket;
  late SendPort? notificationSendPort;
  bool initialized = false;
  static final Uint8List notificationReply = Uint8List.fromList(("DONE").codeUnits);
  RService._singletonInstance();

  static final RService _instance = RService._singletonInstance();

  static RService get rInstance => _instance;
  static const String dump = "DUMP";
  static final Map<String, Function> mapFunction = {
    'POST_LIKE': postLike, // done
    'POST_DISLIKE': postDislike, // done
    'FETCH_LIKES': fetchLikes, // done
    'FETCH_COMMENTS': fetchComments, // done
    'FETCH_FOLLOWERS': fetchFollowerAccounts, // done
    'FETCH_FOLLOWING': fetchFolloweeAccounts, // done
    'ADD_NEW_POST': addNewPost, // done
    'ADD_NEW_STORY': addNewStory, // done
    'POST_COMMENT': postComment, // done
    'FETCH_USER_NOTIFICATIONS': fetchUserNotifications, // done
    'SUBSCRIBE_TO_NOTIFICATIONS': subscribeToNotificationStream, //done
    'UPDATE_LATEST_NOTIFICATIONS_VIEW': updateLatestNotificationView,
    'FETCH_USER_CURRENT_STORIES': fetchCurrentPersonalStoriesNew, // done
   // 'FETCH_EXTERNAL_USER_STORIES': fetchUserStoriesSetNew, // done
    'FETCH_USER_STORIES_SET': fetchUserStoriesSet, // done
   // 'FETCH_USER_STORIES_NEW_SET': fetchUserStoriesSetNew, // done
    'FETCH_USER_PERSONAL_POSTS': fetchUserPersonalPosts, // done
    'FETCH_USER_POST':fetchUserPost, // done
    'FETCH_USER_TIMELINE_POSTS': fetchUserTimelinePosts, // done
    'FETCH_MEMORY_STORIES': fetchStoriesFromMemory, // done
    'FETCH_USER_MEMORIES_SET': fetchUserMemoriesSet, // done
    'FETCH_STORY_VIEWERS': fetchStoryViewers, // ~ later
    'FETCH_USER_SEARCH_RESULTS': fetchUserSearchResults, //
    'FETCH_EXTERNAL_USER_DETAILS': fetchExternalUserDetails, // done
    'FOLLOW_EXTERNAL_USER': followExternalUser, // done
    'UNFOLLOW_EXTERNAL_USER': unfollowExternalUser, // done
    'FETCH_OLD_NOTIFICATIONS': fetchOldNotifications, //done
    'DELETE_USER_POST': deleteUserPost, // done
    'REFRESH_METADATA': refreshMetaData,
    'FETCH_LATEST_USER_STORIES' : fetchLatestFollowerStoriesAccounts
   // 'UPDATE_USER_METADATA':updateUserMetaData// done
  };

  void sendError(SendPort generalPort, dynamic errorData) {
    generalPort.send(errorData); // 0 : connection failure
  }

  void connectToRSocketServer(
    SendPort mIGSP,
  ) async {
    try {
      // for logout, new rsocket connection
      if (initialized) {
        initialized = false;
        await (rsocket as RSocketRequester).close();
      }
      rsocket = await RSocketConnector.create()
          .acceptor(requestResponseAcceptor((payload) {
        if (payload != null && notificationSendPort != null) {
          var data = cbor.decode(payload.data!.toList());
          notificationSendPort!.send([UiNotification.fromMapData(data! as Map)]);
        }
        return Future.value(Payload.from(null, notificationReply));
      })).connect(("ws://192.168.29.136:7000/rsocket"));

      initialized = true;
      mIGSP.send(1);
      // connection success
    } catch (e) {
      notificationSendPort = null;
      initialized = false;
      sendError(mIGSP, 0);
    }
  }

  void rsocketOperations(
      Map message, SendPort mainIsolateSendPorts, SendPort errorPort) {
    String operation = message['operation'];
    Map<String, dynamic> messageData = message['data'];
    SendPort? sp = message['temp_port'];
    if(operation.compareTo('FETCH_USER_NOTIFICATIONS') == 0) notificationSendPort = sp;
    
    if ((rsocket as RSocketRequester).closed) {
      if (sp != null) {
        sendError(errorPort, 'CONNECTION_LOST');
        sp.send([]);
      }
      return;
    }

    (mapFunction[operation]!(rsocket, messageData) as Future).then((value) {
      if (sp == null) return;
      sp.send([value]);
    }, onError: (error) async {
      notificationSendPort = null;
      sendError(errorPort, 'CONNECTION_LOST');
      if (sp == null) return;
      sp.send([]);
    });
  }

/*

    Testing and Deprecated

   */

// static Future<void> startRService(SendPort generalPort, SendPort storyPort,
//     SendPort notificationPort) async {
//   try {
//     if (connectionState == 1) {
//       rsocket = await RSocketConnector.create()
//           .acceptor(requestResponseAcceptor((payload) {
//         MetadataEntry metadataEntry =
//             CompositeMetadata.fromU8Array(payload!.metadata!).first;
//         // check if data is notification (More Request->Response[Server->Client] interactions may be added in future);
//         String dataType = String.fromCharCodes(metadataEntry.content!);
//         if (dataType == 'NOTIFICATION') {
//           storyPort.send(payload);
//         }
//         return Future.value(Payload.from(null, fetchedNotification));
//       }))
//      .connect(("ws://localhost:7000/rsocket"));
//       connectionState = 0;
//     }
//   } catch (e) {
//     connectionState = 1;
//     sendError(generalPort);
//     return;
//   }
// }
//
// static void startUserServices(
//     SendPort generalPort, SendPort notificationPort) {
//   Future.delayed(const Duration(milliseconds: 500)).then((value) async {
//     try {
//       var res = await rsocket!
//           .requestResponse!(Payload.from(null, null)); // For Notifications
//       notificationPort.send(res);
//     } catch (e) {
//       if (connectionState == 0) {
//         sendError(generalPort);
//       }
//       connectionState = 1;
//     }
//   });
// }
}
