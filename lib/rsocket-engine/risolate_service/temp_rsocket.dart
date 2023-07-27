// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:cbor/simple.dart';
// import 'package:http/http.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// import 'main_isolate_engine.dart';
// import 'lib/io/bytes.dart';
// import 'lib/metadata/composite_metadata.dart';
// import 'lib/payload.dart';
// import 'lib/rsocket.dart';
// import 'lib/rsocket_connector.dart';
// import 'lib/shelf.dart';
//
// const String HEADER_POST_ACCOUNTNAME_MIME = "message/post.creator.accountname";
// const String HEADER_LAST_STORY_INSTANT = "message/last.story.instant";
// const String HEADER_POST_CAPTION_MIME = "message/post.creator.caption";
// const String MIME_FILE_EXTENSION = "message/x.upload.file.extension";
// const String MIME_FILE_NAME = "message/x.upload.file.name";
// const String MIME_STORY_ISMEMORY = "message/story.ismemory";
// final Uint8List imageEXT = Uint8List.fromList("jpg".codeUnits);
//
// void main() async {
//   // engineStart();
// }
//
// Future<void> checkConnection() async {
//   // Uri u = Uri.parse("ws://localhost:7000/rsocket");
//   // WebSocketChannel.connect(u);
//   var requester =
//       await RSocketConnector.create().connect(("ws://localhost:7000/rsocket"));
//   Future.delayed(const Duration(seconds: 15), () {
//    // requester.close();
//   }).then((value) async =>
//       await requester.fireAndForget!(Payload.from(null, null)));
// }
//
// Future<void> checkNotif() async {
//   Map<String, dynamic> user = {};
//   user['accountname'] = 'dxtk';
//   var snotif = cbor.encode(user);
//   CompositeMetadata compositeMetadata2 = CompositeMetadata(RSocketByteBuffer());
//   compositeMetadata2.addMetadata(
//       MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
//   compositeMetadata2
//       .addMetadata(RoutingMetadata("rsocket.start.notification.services", []));
//   var payres = "201".codeUnits;
//   Uint8List dd = Uint8List.fromList(payres);
//   CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
//   compositeMetadata.addMetadata(
//       MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x21)!));
//   List<int> list = 'mydata'.codeUnits;
//   Uint8List bytes = Uint8List.fromList(list);
//   var requester = await RSocketConnector.create()
//       .acceptor(requestResponseAcceptor((payload) {
//     var real = cbor.decode(payload!.data!.toList()) as List;
//     print(real);
//     return Future.value(Payload.from(compositeMetadata.toUint8Array(), dd));
//   })).connect(("ws://localhost:7000/rsocket"));
//   print('connection made!');
//
//   var response = await requester.requestResponse!(Payload.from(
//       compositeMetadata2.toUint8Array(), Uint8List.fromList(snotif)));
//
//   // Future.delayed(const Duration(seconds: 15),(){
//   //   requester.close();
//   // });
// }
//
// Future<void> ck() async {
//   RoutingMetadata routingMetadata = RoutingMetadata("rsoc", []);
//   CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
//   compositeMetadata.addMetadata(routingMetadata);
//   List<int> list = 'mydata'.codeUnits;
//   Uint8List bytes = Uint8List.fromList(list);
//   var requester =
//       await RSocketConnector.create().connect(("ws://localhost:7000/rsocket"));
//
//   print("now waiting for response");
//
//   var response = await requester
//       .requestResponse!(Payload.from(compositeMetadata.toUint8Array(), bytes));
//   requester.close();
//   print(response.data);
// }
//
// // Post post from user dxtk
//
// Future<void> addNewPost() async {
//   String accountname = "dxtk";
//   String caption = "test caption";
//
//   Uint8List aname = Uint8List.fromList(accountname.codeUnits);
//   Uint8List cap = Uint8List.fromList(caption.codeUnits);
//   Uint8List imgBytes =
//       new File("/home/kaustubh/Desktop/lambo.jpg").readAsBytesSync();
//
//   List<MetadataEntry> metadatas = [
//     RoutingMetadata("rsocket.upload.post", []),
//   ];
//
//   CompositeMetadata compositeMetadata =
//       CompositeMetadata.fromEntries(metadatas);
//
//   compositeMetadata.addWellKnownMimeType(
//       0x7a, Uint8List.fromList("image/jpeg".codeUnits));
//
//   compositeMetadata.addExplicitMimeType(
//       "message/x.upload.file.extension", imageEXT);
//   compositeMetadata.addExplicitMimeType("message/x.upload.file.name", aname);
//   compositeMetadata.addExplicitMimeType(HEADER_POST_ACCOUNTNAME_MIME, aname);
//   compositeMetadata.addExplicitMimeType(HEADER_POST_CAPTION_MIME, cap);
//
//   // WebSocket websocket = await WebSocket.connect("tcp://0.0.0.0:42252");
//   var requester =
//       await RSocketConnector.create().connect(("ws://localhost:7000/rsocket"));
//
//   print("now waiting for response");
//
//   var response = await requester.requestResponse!(
//       Payload.from(compositeMetadata.toUint8Array(), imgBytes));
//   requester.close();
//   print(response.data.toString());
// }
//
// // add comment  on post
//
// Future<void> addComment() async {
//   String comment = "this is my comment";
//   var postid = 1;
//   String accountname = "dxtk";
//   Map<String, dynamic> map = {};
//   map["onpostid"] = postid;
//   map["text"] = comment;
//   map["accountname"] = accountname;
//
//   var payloadData = cbor.encode(map);
//
//   CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
//   compositeMetadata.addMetadata(
//       MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
//   compositeMetadata.addMetadata(RoutingMetadata("rsocket.post.comment", []));
//   var requester =
//       await RSocketConnector.create().connect(("ws://localhost:7000/rsocket"));
//
//   print("now waiting for response");
//
//   var response = await requester.requestResponse!(Payload.from(
//       compositeMetadata.toUint8Array(), Uint8List.fromList(payloadData)));
//   requester.close();
//   print(response.data);
// }
//
// Future<void> addLike() async {
//   var postid = "1";
//   String accountname = "dxtk";
//   Map<String, dynamic> map = {};
//   map["onpostid"] = postid;
//
//   map["accountname"] = accountname;
//
//   var payloadData = cbor.encode(map);
//
//   CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
//   compositeMetadata.addMetadata(
//       MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
//   compositeMetadata.addMetadata(RoutingMetadata("rsocket.post.like", []));
//   var requester =
//       await RSocketConnector.create().connect(("ws://localhost:7000/rsocket"));
//
//   print("now waiting for response");
//
//   var response = await requester.fireAndForget!(Payload.from(
//       compositeMetadata.toUint8Array(), Uint8List.fromList(payloadData)));
//   requester.close();
//   // print(response.data);
// }
//
// Future<void> fetchPost() async {
//   // var postid = "1";
//   var maxIndex = "-1";
//   var minIndex = "-1";
//
//   String accountname = "amber";
//   Map<String, dynamic> map = {};
//   map["maxIndex"] = maxIndex;
//   map["minIndex"] = minIndex;
//
//   map["accountname"] = accountname;
//
//   var payloadData = cbor.encode(map);
//
//   CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
//   compositeMetadata.addMetadata(
//       MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
//   compositeMetadata.addMetadata(RoutingMetadata("rsocket.fetch.posts", []));
//   var requester =
//       await RSocketConnector.create().connect(("ws://localhost:7000/rsocket"));
//
//   print("now waiting for response");
//
//   var response = await requester.requestResponse!(Payload.from(
//       compositeMetadata.toUint8Array(), Uint8List.fromList(payloadData)));
//   requester.close();
//   // var json = jsonDecode(response.toString());
//
//   var resdata =
//       cbor.decode(Uint8List.fromList(response.data!), parseDateTime: true);
//   var v1 = (resdata as Map<Object?, Object?>)["maxIndex"];
//   var v2 = (resdata)["minIndex"];
//   var v3 = (resdata)["userPosts"];
//   var milli =
//       (((((v3 as List).first as Map)['ctime'] as List).last as int) / 1000000 +
//               15000)
//           .toInt();
//
//   print(milli);
//   DateTime time = DateTime.fromMillisecondsSinceEpoch(milli, isUtc: true);
//   print(time);
//   print(v1);
//   print(v2);
//   print(v3);
//   // print(json);
// }
//
// Future<void> postStory() async {
//   var postid = "1";
//   String name = "amber";
//
//   CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
//   compositeMetadata.addMetadata(
//       MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
//   compositeMetadata.addMetadata(RoutingMetadata("rsocket.upload.story", []));
//   var requester =
//       await RSocketConnector.create().connect(("ws://localhost:7000/rsocket"));
//
//   print("now waiting for response");
//
//   var response = await requester.requestResponse!(Payload.from(
//       compositeMetadata.toUint8Array(), Uint8List.fromList(name.codeUnits)));
//   requester.close();
//   // print(response.data);
// }
//
// Future<void> fetchStory() async {
//   // var postid = "1";
//   var maxIndex = "-1";
//   var minIndex = "-1";
//
//   String accountname = "dxtk";
//
//   CompositeMetadata compositeMetadata = CompositeMetadata(RSocketByteBuffer());
//   compositeMetadata.addMetadata(
//       MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x21)!));
//   compositeMetadata.addMetadata(RoutingMetadata("rsocket.fetch.stories", []));
//   var requester =
//       await RSocketConnector.create().connect(("ws://localhost:7000/rsocket"));
//
//   print("now waiting for response");
//
//   var response = await requester.requestResponse!(Payload.from(
//       compositeMetadata.toUint8Array(),
//       Uint8List.fromList(accountname.codeUnits)));
//   requester.close();
//   // var json = jsonDecode(response.toString());
//
//   var resData =
//       cbor.decode(Uint8List.fromList(response.data!), parseDateTime: true);
//   var map = (resData as Map);
//   print(map);
//
//   requester.close();
// }
//
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// main1() async {
//   List<int> list = 'mydata'.codeUnits;
//   Uint8List bytes = Uint8List.fromList(list);
//
//   // WebSocket websocket = await WebSocket.connect("tcp://0.0.0.0:42252");
//   var requester =
//       await RSocketConnector.create().connect(("ws://localhost:7000/rsocket"));
//
//   print("now waiting for response");
//   var response = await requester.requestResponse!(Payload.from(null, bytes));
//   requester.close();
//   print(response.data);
// }
//
// Future<void> main56() async {
//   Map<String, dynamic> map = {};
//   map["accountname"] = "Audi";
//   map["onpostid"] = "15";
//   map["text"] = "this is comment!";
//
//   var cb = cbor.encode(map);
//   Uint8List main = Uint8List.fromList(cb);
//
//   List<int> list = 'this is client response!'.codeUnits;
//   Uint8List bytes = Uint8List.fromList(list);
//
//   Uint8List imgBytes =
//       File("/home/kaustubh/Desktop/lambo.jpg").readAsBytesSync();
//
//   List<int> list2 = 'kk5kk'.codeUnits;
//   Uint8List bytes2 = Uint8List.fromList(list2);
//   RSocketConnector connector =
//       RSocketConnector.create().acceptor(requestResponseAcceptor((payload) {
//     //  print(convertor(payload!.data!));
//     return Future.value(Payload.from(null, bytes));
//   }));
//
//   var rsocket = await connector.connect("ws://localhost:7000/rsocket");
//   var response = await rsocket.requestResponse!(Payload.from(
//       // MetadataEntry.fromContent(Uint8List.fromList("elements41".codeUnits), "message/post.creator.accountname",2).content
//       gg().toUint8Array(),
//       main));
//   //
//   //  var response = await rsocket.requestResponse!(
//   //
//   //
//   // // Payload.fromText("", "bytes2")
//   //      Payload.from(
//   //          gg().toUint8Array(),
//   //         // bytes,
//   //
//   //         bytes
//   //     )
//   //  );
//   //
//   //
//   print(response);
//
//   // rsocket.close();
// }
//
// Future<void> main562() async {
//   Map<String, dynamic> map = {};
//   map["onpostid"] = "74";
//   map["accountname"] = "Shinzo";
//
//   var cb = cbor.encode(map);
//   Uint8List main = Uint8List.fromList(cb);
//
//   List<int> list = 'this is client response!'.codeUnits;
//   Uint8List bytes = Uint8List.fromList(list);
//
//   Uint8List imgBytes =
//       File("/home/kaustubh/Desktop/lambo.jpg").readAsBytesSync();
//
//   List<int> list2 = 'kk5kk'.codeUnits;
//   Uint8List bytes2 = Uint8List.fromList(list2);
//   RSocketConnector connector =
//       RSocketConnector.create().acceptor(requestResponseAcceptor((payload) {
//     //  print(convertor(payload!.data!));
//     return Future.value(Payload.from(null, bytes));
//   }));
//
//   var rsocket = await connector.connect("ws://localhost:7000/rsocket");
//   var response = await rsocket.requestResponse!(Payload.from(
//       // MetadataEntry.fromContent(Uint8List.fromList("elements41".codeUnits), "message/post.creator.accountname",2).content
//       gg().toUint8Array(),
//       main));
//   //
//   //  var response = await rsocket.requestResponse!(
//   //
//   //
//   // // Payload.fromText("", "bytes2")
//   //      Payload.from(
//   //          gg().toUint8Array(),
//   //         // bytes,
//   //
//   //         bytes
//   //     )
//   //  );
//   //
//   //
//   print(response);
//
//   // rsocket.close();
// }
//
// CompositeMetadata gg() {
//   List<int> list = 'client'.codeUnits;
//   Uint8List acc = Uint8List.fromList(list);
//
//   list = 'caption'.codeUnits;
//   Uint8List caption = Uint8List.fromList(list);
//
//   list = 'fname'.codeUnits;
//   Uint8List fname = Uint8List.fromList(list);
//
//   list = 'jpg'.codeUnits;
//   Uint8List ext = Uint8List.fromList(list);
//
// //  RSocketByteBuffer rb = RSocketByteBuffer.fromUint8List(bytes);
//   List<String> tag = ["abc"];
//
//   List<MetadataEntry> ll = [
//     RoutingMetadata("rsocket.post.like", []),
//     // MetadataEntry.fromContent(Uint8List.fromList("elements1".codeUnits), "message/accountname"),
//     // MetadataEntry.fromContent(Uint8List.fromList("elements41".codeUnits), "text/plain"),
//     // TaggingMetadata('message/accountname', tag),
//     // MetadataEntry.fromContent(Uint8List.fromList("elements3".codeUnits), "plain/text",2),
//     // MetadataEntry.fromContent(Uint8List.fromList("elements4".codeUnits), "plain/text",3)
//     // MetadataEntry.fromContent(Uint8List.fromList("metadata!".codeUnits), "text/plain",0),
//     //   MetadataEntry.fromContent(Uint8List.fromList("2!".codeUnits), "text/plain",1),
//     //  MetadataEntry.fromContent(Uint8List.fromList("elements1".codeUnits), 'message/x.accountname'),
//     // MetadataEntry.fromContent(Uint8List.fromList("elements3".codeUnits), "message/x.upload.file.extension"),
//     // MetadataEntry.fromContent(Uint8List.fromList("elements4".codeUnits), "message/x.upload.file.name")
//   ];
//
//   CompositeMetadata compositeMetadata = CompositeMetadata.fromEntries(ll);
//
//   // FOR POST UPLOAD!
//
//   //  compositeMetadata.addExplicitMimeType("message/post.creator.accountname", acc);
//   // compositeMetadata.addExplicitMimeType("message/post.creator.caption", caption);
//   // compositeMetadata.addExplicitMimeType("message/x.upload.file.extension", ext);
//   // compositeMetadata.addExplicitMimeType("message/x.upload.file.name", fname);
//   // compositeMetadata.addMetadata(MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x1a)!));
//
//   // FOR COMMENT
//
//   compositeMetadata.addMetadata(
//       MessageMimeTypeMetadata(WellKnownMimeType.getMimeType(0x01)!));
//
//   return compositeMetadata;
// }
//
// Future<void> main3() async {
//   List<int> list = 'this is client response!'.codeUnits;
//   Uint8List bytes = Uint8List.fromList(list);
//
//   List<int> list2 = 'kkkk'.codeUnits;
//   Uint8List bytes2 = Uint8List.fromList(list2);
//   RSocketConnector connector =
//       RSocketConnector.create().acceptor(requestStreamAcceptor((payload) {
//     List<Payload> list = [Payload.from(null, bytes2)];
//     return Stream.fromIterable(list);
//   }));
//   var rsocket = await connector.connect("ws://localhost:7000/rsocket");
//   // var req = await rsocket.requestResponse!(Payload.from(null, bytes2));
//   // print(convertor(req!.data!));
// }
//
// Future<void> main63() async {
//   List<int> list = 'this is client response!'.codeUnits;
//   Uint8List bytes = Uint8List.fromList(list);
//
//   List<int> list2 = 'kkkk'.codeUnits;
//   Uint8List bytes2 = Uint8List.fromList(list2);
//   RSocketConnector connector =
//       RSocketConnector.create().acceptor(requestResponseAcceptor((payload) {
//     //  print(convertor(payload!.data!));
//     return Future.value(Payload.from(null, bytes));
//   }));
//   var rsocket = await connector.connect("ws://localhost:7000/rsocket");
// }
//
// String convertor(Uint8List inputAsUint8List) {
//   String s = new String.fromCharCodes(inputAsUint8List);
//   return s;
// }
