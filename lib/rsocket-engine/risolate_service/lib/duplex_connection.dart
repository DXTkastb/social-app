import 'dart:typed_data';

import 'package:universal_io/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'io/bytes.dart';
import 'rsocket.dart';

abstract class DuplexConnection implements Closeable, Availability {
  double _availability = 1.0;
  TcpChunkHandler? receiveHandler;
  CloseHandler? closeHandler;

  void init();

  void write(Uint8List chunk);

  @override
  double availability() {
    return _availability;
  }
}

typedef TcpChunkHandler = void Function(Uint8List chunk);
typedef CloseHandler = void Function();

class TcpDuplexConnection extends DuplexConnection {
  Socket socket;
  bool closed = false;

  TcpDuplexConnection(this.socket);

  @override
  void init() {
    socket.listen((data) {
      receiveHandler!(data);
    }, onDone: () {
      close();
    }, onError: (e) {
      close();
    });
  }

  @override
  void close() {
    if (!closed) {
      closed = true;
      _availability = 0.0;
      socket.close();
      closeHandler?.call();
    }
  }

  void closeConnection() {
    close();
  }

  @override
  void write(Uint8List chunk) {
    socket.add(chunk);
  }
}

class WebSocketDuplexConnection extends DuplexConnection {
  WebSocketChannel webSocket;
  bool closed = false;

  WebSocketDuplexConnection(this.webSocket);

  @override
  void init() {
    webSocket.stream.listen((message) {
      var data = message as List<int>;
      var frameLenBytes = i24ToBytes(data.length);
      receiveHandler!(Uint8List.fromList(frameLenBytes + data));
    }, onDone: () {
      closeConnection();
    }, onError: (e) {
      closeConnection();
    });
  }

  @override
  void close() {
    if (!closed) {
      closed = true;
      _availability = 0.0;
      closeHandler?.call();
    }
  }

  closeConnection() async {
    close();
    await webSocket.sink.close();
  }

  @override
  void write(Uint8List chunk) {
    //remove frame length: 3 bytes
    if(!closed) webSocket.sink.add(chunk.sublist(3));
  }
}

Future<DuplexConnection> connectRSocket(
    String url, TcpChunkHandler handler) async {
  var uri = Uri.parse(url);
  var scheme = uri.scheme;
  if (scheme == 'tcp') {
    var socketFuture = Socket.connect(uri.host, uri.port);
    return socketFuture.then((socket) => TcpDuplexConnection(socket));
  }

  if (scheme == 'ws' || scheme == 'wss') {
    final websocket = WebSocketChannel.connect(
      Uri.parse(url),
    );
    await websocket.ready;
    return Future.value(WebSocketDuplexConnection(websocket));
  } else {
    return Future.error('${scheme} unsupported');
  }
}
