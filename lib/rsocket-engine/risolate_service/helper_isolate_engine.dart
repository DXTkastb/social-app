import 'dart:isolate';

import 'rsocket_service/rservice.dart';

Future<void> isolateEntry(Map<String, SendPort> ports) async {
  var mainIsolateGeneralSendPort = ports['general_port']!; // mIGSP
  var mainIsolateErrorSendPort = ports['error_port']!;
  ReceivePort isolateGeneralPort = ReceivePort();
  mainIsolateGeneralSendPort.send(isolateGeneralPort.sendPort);


  await for (final message in isolateGeneralPort) {
    if (message is String) {
      switch (message) {
        case "RSOCKET_SETUP_CONNECTION":

          RService.rInstance.connectToRSocketServer(mainIsolateGeneralSendPort);
          break;
      }
    } else if (message is Map) {
        RService.rInstance.rsocketOperations(message,mainIsolateGeneralSendPort,mainIsolateErrorSendPort);
    } else {
      break;
    }
  }
  Isolate.exit();
}
