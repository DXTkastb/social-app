import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/login-signup/login.dart';
import '/screens/user_main_ui.dart';
import '/change_notifiers/app_state_notifier.dart';
import '/error_screens/network_error_screen.dart';

/*
  This class is alternative to dynamic Routing. Set this class as home property of MaterialApp and remove initial route property.
 */

class AppInitialPage extends StatelessWidget {
  const AppInitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(builder: (ctx, appState, child) {
      int state = appState.getState();
      Widget widget;
      if (state == 1) {
        widget = const InitializationUIView();
      } else if (state == 2) {
        widget = const LoginPage();
      } else {
        widget = const NetworkErrorPage();
      }

      return PageTransitionSwitcher(
        duration: const Duration(milliseconds: 400),
        key: const Key('page_transition'),
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) {
          return SlideTransition (

              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(1.0, 0.0),
              ).animate(secondaryAnimation),
              child:
              // child

              SlideTransition(position: Tween<Offset>(
                begin: Offset.zero,
                end: Offset.zero,
              ).animate(primaryAnimation),
              child: child,
              )

              // FadeTransition(
              //   opacity: Tween<double>(
              //     begin: 0.0,
              //     end: 1.0,
              //   ).animate(primaryAnimation),
              //   child: child,
              // ),

              );
        },
        child: widget,
      );
    });
  }
}
