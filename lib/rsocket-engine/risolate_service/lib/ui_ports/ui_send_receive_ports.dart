import 'dart:isolate';

class UiIsolatePorts {
  static ReceivePort rsocketConnectionErrorPort = ReceivePort();
  static ReceivePort rsocketFetchPosts = ReceivePort();
  static ReceivePort rsocketFetchStories = ReceivePort();
  static ReceivePort generalPort = ReceivePort();
}
