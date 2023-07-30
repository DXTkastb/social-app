import 'dart:io';
import 'dart:typed_data';

import 'package:cbor/simple.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/like.dart';
import 'package:socio/data/user_details.dart' as usr;
import '../communication_data/communication_lib.dart';
import '../communication_data/fetch_ff_query.dart';
import '../lib/io/bytes.dart';
import '../lib/metadata/composite_metadata.dart';
import '../lib/metadata/wellknown_mimetype.dart';
import '../lib/payload.dart';
import '../lib/rsocket.dart';

void main() {
}

Uint8List getBytesDataFromCbor(List<int> data) {
  return Uint8List.fromList(data);
}

/*
    fetching current_personal user stories
    timestamp   : now()-86400 -> now()
 */

@deprecated
Future<UserStory> fetchCurrentPersonalStories(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(FetchStoryQuery(dataMap['accountName'],
          dataMap['instant1'], dataMap['instant2'], dataMap['viewerName'])
      .toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());

  compositeMetadata.addMetadata(
      MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.fetch.user.story.newapi", []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  var x = cbor.decode(response.data!.toList())!;
  return UserStory(dataMap: x);
}

Future<List<Story>> fetchCurrentPersonalStoriesNew(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = (dataMap['accountName'] as String).codeUnits;
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());

  compositeMetadata.addMetadata(
      MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.fetch.user.story.exp", []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), Uint8List.fromList(payloadData)));
  var x = cbor.decode(response.data!.toList())!;
  List<Story> mylist =
   (x as List).map((e) => Story.fromDynamicMap(e)).toList();
  return mylist;
}

/*
    fetching external user stories
    timestamp   : previous_timestamp -> now()
 */

@deprecated
Future<UserStory> fetchExternalUserStories(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(FetchStoryQuery(dataMap['accountName'],
          dataMap['instant1'], dataMap['instant2'], dataMap['viewerName'])
      .toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(
      MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.fetch.user.story.newapi", []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  var x = cbor.decode(response.data!.toList())!;
  return UserStory(dataMap: x);
}


/*
    fetch user stories via memories
 */

Future<UserStory> fetchStoriesFromMemory(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(dataMap['memoryId']);
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(
      MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.fetch.user.memory.stories", []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  var x = cbor.decode(response.data!.toList())!;
  return UserStory(dataMap: x);
}

/*
    fetching user timeline stories set / new stories set
 */
// ****************************************************??????????????????????????????????????????????
// ****************************************************??????????????????????????????????????????????
// ****************************************************??????????????????????????????????????????????


Future<List<String>> fetchLatestFollowerStoriesAccounts(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = (dataMap['accountName'] as String).codeUnits;
      CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(
      MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
  compositeMetadata.addMetadata(RoutingMetadata(
      "rsocket.fetch.user.follower.stories", []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), Uint8List.fromList(payloadData)));
  var x = (cbor.decode(response.data!.toList())! as List).map((e) => e! as String).toList();
  return x;
}


// ****************************************************??????????????????????????????????????????????
// ****************************************************??????????????????????????????????????????????
// ****************************************************??????????????????????????????????????????????


Future<UserStorySet> fetchUserStoriesSet(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(FetchStorySetQuery(
          dataMap['accountName'], dataMap['instant1'], dataMap['instant2'])
      .toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(
      MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
  compositeMetadata.addMetadata(RoutingMetadata(
      "rsocket.fetch.user.storyset.newapi", // first fetch for user
      []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  var x = cbor.decode(response.data!.toList())!;

  return UserStorySet(dataMap: x);
}

Future<UserStorySet> fetchUserStoriesSetNew(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(FetchStorySetQuery(
          dataMap['accountName'], dataMap['instant1'], dataMap['instant2'])
      .toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(
      MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
  compositeMetadata.addMetadata(
      RoutingMetadata("rsocket.fetch.user.newstoryset.newapi", []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  var x = cbor.decode(response.data!.toList())!;
  return UserStorySet(dataMap: x);
}


// ****************************************************??????????????????????????????????????????????
// ****************************************************??????????????????????????????????????????????
// ****************************************************??????????????????????????????????????????????
// ****************************************************??????????????????????????????????????????????
// ****************************************************??????????????????????????????????????????????
// ****************************************************??????????????????????????????????????????????


/*
    fetching user personal posts
 */



Future<UserPersonalPosts> fetchUserPersonalPosts(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = dataMap['accountName'];
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.fetch.user.personal.posts", []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(),
      Uint8List.fromList(payloadData.codeUnits)));
  return UserPersonalPosts(dataMap: cbor.decode(response.data!.toList())!);
}

/*
    fetching user post
 */

Future<TimelinePost> fetchUserPost(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(dataMap['postid']);
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.get.user.post", []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  return TimelinePost.fromDynamicMap(
      cbor.decode(response.data!.toList())! as Map);
}

/*
    fetch user timeline posts
 */

Future<UserTimelinePosts> fetchUserTimelinePosts(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(FetchUserTimelinePostsQuery(
          dataMap['accountName'], dataMap['maxIndex'], dataMap['minIndex'])
      .toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(
      MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.fetch.posts", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  var x = cbor.decode(response.data!.toList())!;
  return UserTimelinePosts(dataMap: x);
}

Future<int> deleteUserPost(
    RSocket rSocketRequester, Map<String, dynamic> map) async {
  var payloadData = cbor.encode(map);
  var p = getBytesDataFromCbor(payloadData);

  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(
      MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.post.delete", []));
  var response = await rSocketRequester
      .requestResponse!(Payload.from(compositeMetadata.toUint8Array(), p));
  var x = cbor.decode(response.data!.toList())!;
  return (x as int);
}

/*
    fetch user memories
 */

Future<MemoriesSet> fetchUserMemoriesSet(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = dataMap['accountName'];
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.fetch.memories", []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(),
      Uint8List.fromList(payloadData.codeUnits)));
  var x = cbor.decode(response.data!.toList())!;
  var mset = MemoriesSet(listData: x);
  return mset;
}

/*
  fetch story viewers
 */

Future<UserStoryViewersList> fetchStoryViewers(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(
      FetchStoryViewsQuery(dataMap['accontName'], dataMap['storyID']).toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.fetch.story.views.newapi", []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  var x = cbor.decode(response.data!.toList())!;
  return UserStoryViewersList(listData: x);
}

/*
    fetch user search matches
 */

Future<UserSearchResults> fetchUserSearchResults(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = dataMap['searchedText'];
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.search.user", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(),
      Uint8List.fromList(payloadData.codeUnits)));

  return UserSearchResults(
      listOfUsers: cbor.decode(response.data!.toList())!,
      queryNumber: dataMap['queryNumber']);
}

/*
    fetch external user details
 */

Future<User> fetchExternalUserDetails(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(
      ExternalUserQuery(dataMap['accountName'], dataMap['searchedAccountName'])
          .toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.get.external.user", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));

  var x = cbor.decode(response.data!.toList())!;
  return User.fromExternalFetch(userData: x);
}

/*
    follow user
 */

Future<int> followExternalUser(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  Map<String, String> relationData = {
    "followee": dataMap['followee'],
    "follower": dataMap['follower']
  };
  var payloadData = cbor.encode(relationData);
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.follow.user", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  var x = cbor.decode(response.data!.toList())! as int;
  return x;
}

/*
    unfollow user
 */

Future<int> unfollowExternalUser(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  Map<String, String> relationData = {
    "followee": dataMap['follower'],
    "follower": dataMap['followee']
  };
  var payloadData = cbor.encode(relationData);
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.unfollow.user", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));

  var x = cbor.decode(response.data!.toList())! as int;
  return x;
}

/*
    unfollow user
 */

Future<usr.User> refreshMetaData(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(dataMap['accountName']);
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.fetch.user.metadata", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), Uint8List.fromList((dataMap['accountName'] as String).codeUnits)));
  var x = cbor.decode(response.data!.toList())! ;
  x = x as Map<Object?,dynamic>;
  return usr.User.fromMetaData(userData: x);
}

Future<User> updateUserMetaData(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(dataMap);
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.fetch.user.metadata", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));

  var x = cbor.decode(response.data!.toList())! as Map<String, dynamic>;
  return User.fromMetaData(userData: x);
}

/*
    post comment
 */

Future<int> postComment(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(CommentActivityQuery(dataMap['onpostid'],
          dataMap['accountname'], dataMap['postCreatorName'], dataMap['text'])
      .toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.post.comment", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));

  var x = cbor.decode(response.data!.toList())! as int;
  return x;
}

/*
    post like
 */

Future<void> postLike(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(LikeActivityQuery(dataMap['onpostid'],
          dataMap['accountName'], dataMap['postCreatorName'])
      .toMap());

  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.post.like", []));

  await rSocketRequester.fireAndForget!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
}

/*
    post dislike
 */

Future<void> postDislike(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(LikeActivityQuery(dataMap['onpostid'],
          dataMap['accountName'], dataMap['postCreatorName'])
      .toMap());

  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.post.dislike", []));

  await rSocketRequester.fireAndForget!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
}

/*
    fetch likes for a post
 */

Future<List<Like>> fetchLikes(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(
      FetchLikeCommentQuery(dataMap['postid'], dataMap['lastFetchId']).toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.fetch.likes", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  var x = cbor.decode(response.data!.toList())!;
  return (x as List).map((e) {
    Map map = e;
    return Like(e['id'], e['accountname'], e['onpostid']);
  }).toList(growable: false);
}

/*
    fetch comments for a post
 */

Future<List<Comment>> fetchComments(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(
      FetchLikeCommentQuery(dataMap['postid'], dataMap['lastFetchId']).toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.fetch.comments", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));

  var x = cbor.decode(response.data!.toList())!;

  return (x as List).map((e) {
    e = e as Map;
    return Comment(
        e['commentid'], e['onpostid'], e['text'], e['accountname'], null);
  }).toList(growable: false);
}

Future<Map<String, dynamic>> fetchFollowerAccounts(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(
      FetchFFQuery(dataMap['accountName'], dataMap['lastAccountName']).toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.fetch.followers", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  var x = cbor.decode(response.data!.toList())!;
  x = (x as List).map((e) => e as String).toList();
  return {'data': (x), 'queryNumber': dataMap['queryNumber']};
}

Future<Map<String, dynamic>> fetchFolloweeAccounts(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor.encode(
      FetchFFQuery(dataMap['accountName'], dataMap['lastAccountName']).toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(RoutingMetadata("rsocket.fetch.following", []));
  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
  var x = cbor.decode(response.data!.toList())!;
  x = (x as List).map((e) => e as String).toList();
  return {'data': (x), 'queryNumber': dataMap['queryNumber']};
}

/*
    Add new Post
 */

Future<Post> addNewPost(
  RSocket rSocketRequester,
  Map<String, dynamic> dataMap,
) async {
  String fileName =
      '${dataMap['accountName']}_post_${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
  String caption = dataMap['caption'];

  Uint8List aname = Uint8List.fromList(dataMap['accountName'].codeUnits);
  Uint8List cap = Uint8List.fromList(caption.codeUnits);
  Uint8List imgBytes = File(dataMap['filePath']).readAsBytesSync();

  List<MetadataEntry> metadata = [
    RoutingMetadata("rsocket.upload.post", []),
  ];

  CompositeMetadata compositeMetadata = CompositeMetadata.fromEntries(metadata);

  compositeMetadata.addWellKnownMimeType(
      0x7a, Uint8List.fromList("image/jpeg".codeUnits));

  compositeMetadata.addExplicitMimeType(
      "message/x.upload.file.extension", imageEXT);
  compositeMetadata.addExplicitMimeType("message/x.upload.file.name",
      Uint8List.fromList(fileName.codeUnits.toList()));
  compositeMetadata.addExplicitMimeType(HEADER_POST_ACCOUNTNAME_MIME, aname);
  compositeMetadata.addExplicitMimeType(HEADER_POST_CAPTION_MIME, cap);

  var response = await rSocketRequester.requestResponse!(
      Payload.from(compositeMetadata.toUint8Array(), imgBytes));

  var x = cbor.decode(response.data!.toList(growable: false));
  Post post = Post.fromDynamicMap(x);
  return post;
}

// add new story

Future<Story> addNewStory(
  RSocket rSocketRequester,
  Map<String, dynamic> dataMap,
) async {
  String fileName =
      '${dataMap['accountName']}_story_${DateTime.now().millisecondsSinceEpoch ~/ 1000}';

  Uint8List acname = Uint8List.fromList(dataMap['accountName'].codeUnits);
  Uint8List imgBytes = File(dataMap['filePath']).readAsBytesSync();

  List<MetadataEntry> metadatas = [
    RoutingMetadata("rsocket.upload.story.newapi", []),
  ];
  Uint8List isMemory = Uint8List.fromList(("true").codeUnits);

  CompositeMetadata compositeMetadata =
      CompositeMetadata.fromEntries(metadatas);

  compositeMetadata.addWellKnownMimeType(
      0x7a, Uint8List.fromList("image/jpeg".codeUnits));
  compositeMetadata.addExplicitMimeType(
      "message/x.upload.file.extension", imageEXT);
  compositeMetadata.addExplicitMimeType("message/x.upload.file.name",
      Uint8List.fromList(fileName.codeUnits.toList()));
  compositeMetadata.addExplicitMimeType(HEADER_POST_ACCOUNTNAME_MIME, acname);
  compositeMetadata.addExplicitMimeType(MIME_STORY_ISMEMORY, isMemory);

  var response = await rSocketRequester.requestResponse!(
      Payload.from(compositeMetadata.toUint8Array(), imgBytes));

  var x = cbor.decode(response.data!.toList(growable: false));
  return Story.fromDynamicMap(x);
}

/*
    fetch user notifications
 */

Future<UiNotificationMessages> fetchUserNotifications(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  String payloadData = dataMap['accountName'];
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.fetch.user.notifications", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(),
      Uint8List.fromList(payloadData.codeUnits)));

  var x = cbor.decode(response.data!.toList())!;
  return UiNotificationMessages(objects: x);
}

/*
    user subscribe to notificationStream
 */

Future<void> subscribeToNotificationStream(
    RSocket rSocketRequester, Map<String, dynamic> dataMap) async {
  var payloadData = cbor
      .encode(StreamQuery(dataMap['accountName'], dataMap['offset']).toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.user.subscribe.notifications", []));

  await rSocketRequester.fireAndForget!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
}

/*
   update latest notification view mark for user
 */

Future<void> updateLatestNotificationView(
  RSocket rSocketRequester,
  Map<String, dynamic> dataMap,
) async {
  var payloadData = cbor.encode(LatestNotificationViewQuery(
          dataMap['accountName'], dataMap['notificationId'])
      .toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata.addMetadata(
      RoutingMetadata("rsocket.user.latest.notification.mark", []));

  await rSocketRequester.fireAndForget!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));
}

Future<List<UiNotification>> fetchOldNotifications(
  RSocket rSocketRequester,
  Map<String, dynamic> dataMap,
) async {
  var payloadData = cbor.encode(FetchOldNotificationsQuery(
          dataMap['accountName'], dataMap['lastNotificationID'])
      .toMap());
  CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
  compositeMetadata
      .addMetadata(RoutingMetadata("rsocket.fetch.user.old.notifications", []));

  var response = await rSocketRequester.requestResponse!(Payload.from(
      compositeMetadata.toUint8Array(), getBytesDataFromCbor(payloadData)));

  var y = cbor.decode(response.data!.toList())!;
  var dataList = (y as List).map((e) {
    var x = (e! as Map);
    return UiNotification(x['accountname'], x['postid'], x['timeCreated'],
        x['id'], x['notificationText'], x['type']);
  }).toList(growable: false);
  return dataList;
}
