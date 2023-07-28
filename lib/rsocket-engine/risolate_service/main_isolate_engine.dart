import 'dart:isolate';

import 'helper_isolate_engine.dart';

class MainIsolateEngine {
  ReceivePort rPortForPosts = ReceivePort();
  ReceivePort rPostForStories = ReceivePort();
  ReceivePort rNotification = ReceivePort();
  ReceivePort rNetworkConnectionError = ReceivePort();
  ReceivePort generalPort = ReceivePort();
  late SendPort? helperIsolateSendPort;
  late Stream generalPortStream;
  late Stream rPostForStoriesStream;
  late Stream rPostForPostsStream;
  late Stream rNotificationStream;
  late Stream rNetworkConnectionErrorStream;

  MainIsolateEngine._singletonConstructor();

  static final MainIsolateEngine _engine =
      MainIsolateEngine._singletonConstructor();

  static MainIsolateEngine get engine => _engine;

  void engineClose() {
    rPostForStories.close();
    rPortForPosts.close();
    rNotification.close();
    rNetworkConnectionError.close();
    generalPort.close();
  }

  Future<void> engineStart() async {
    Map<String, SendPort> ports = {};
    // ports['notifications_port'] = rNotification.sendPort;
    // ports['stories_port'] = rPostForStories.sendPort;
    // ports['posts_port'] = rPortForPosts.sendPort;
    // ports['network_connection_error_port'] = rNetworkConnectionError.sendPort;
    ports['error_port'] = rNetworkConnectionError.sendPort;
    ports['general_port'] = generalPort.sendPort;
    generalPortStream = generalPort.asBroadcastStream();
    rPostForStoriesStream = rPostForStories.asBroadcastStream();
    rPostForPostsStream = rPortForPosts.asBroadcastStream();
    rNotificationStream = rNotification.asBroadcastStream();
    rNetworkConnectionErrorStream = rNetworkConnectionError.asBroadcastStream();
    await Isolate.spawn<Map<String, SendPort>>(isolateEntry, ports);

    //  final events = StreamQueue<dynamic>(generalPortStream);
    helperIsolateSendPort = await generalPortStream.first;
  }

  void connectToRsocket() {
    helperIsolateSendPort!.send("RSOCKET_SETUP_CONNECTION");
  }

  void sendMessage(Map data) {
    helperIsolateSendPort!.send(data);
  }

  void interruptRscoket() {
    helperIsolateSendPort!.send("RSOCKET_CLOSE_ON_LOGOUT");
  }
}
