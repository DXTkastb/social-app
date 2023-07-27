import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/communication_lib.dart';

import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class UserSearchNotifier extends ChangeNotifier{
  int qnum = 0;
  final port = ReceivePort();
  late final Stream stream;
  Future<List<User>>? search;

  UserSearchNotifier(){
    stream = port.asBroadcastStream();
  }

  void newInput(String input) async {

    // search = Future.value(
    //     [
    //       User.fromSearch(accountname: 'askai', username : 'drogon', profileurl: 'abcr'),
    //       User.fromSearch(accountname: 'askai', username : 'drogon', profileurl: 'abcr'),
    //     ]
    // );
    // if(3>1) {
    //   notifyListeners();
    //   return;
    // }

    if(input.isEmpty) {
      search = null;
    }
    else {
      search = stream.first.then((value) => (value as List)[0].data);
      MainIsolateEngine.engine.sendMessage({
        'operation': 'FETCH_USER_SEARCH_RESULTS',
        'data': {'queryNumber': qnum, 'searchedText': input},
        'temp_port': port.sendPort
      });
    }
    notifyListeners();
  }

  @override
  void dispose(){
    super.dispose();
    port.close();
  }

}