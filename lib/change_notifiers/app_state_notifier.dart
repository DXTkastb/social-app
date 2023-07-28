import 'package:flutter/material.dart';
import 'package:socio/rsocket-engine/risolate_service/main_isolate_engine.dart';

import '../data/user_details.dart';

class AppStateNotifier extends ChangeNotifier{
  User user =  User.getNullUser();
  int _state = 0;

  Future? _rConnect;
  int refreshCounter = 0;
  Future? get rConnect => _rConnect;

  AppStateNotifier(User userData,int newState){
    user = userData;
    _state = newState;
    if(_state == 1){
      initializeRConnect();
    }
  }

  /*
  * 0 : NONE
  * 1 : LOGGEDIN
  * 2 : LOGGEDOUT
  * 3 : SERVER_ERROR : Unable to verify token with server, NOT internet connection error
  * */

  Future<int> connectRoscketFuture() async {
    var c = MainIsolateEngine.engine.generalPortStream.first;
    MainIsolateEngine.engine.connectToRsocket();
    return await c;
  }

  void initializeRConnect(){
    _rConnect = connectRoscketFuture();
  }

  int getState() {
    return _state;
  }

  void update(User user,int newState){
    _state = newState;
    this.user = user;
    if(_state == 1){
      initializeRConnect();
    }
  }

  void updateDataOnStarup(Map updateData){
    user.about = updateData['about'];
    user.link = updateData['link'];
    user.delegation = updateData['delegation'];
    notifyListeners();
  }

  void updateAppUser(){
    notifyListeners();
  }

  void fireLogoutState(){
    refreshCounter = 0;
    _rConnect = null;
    _state = 2;
    user = User.getNullUser();
    MainIsolateEngine.engine.interruptRscoket();
    notifyListeners();
  }

  void refreshConnection(){
    refreshCounter ++;
    notifyListeners();
  }
}