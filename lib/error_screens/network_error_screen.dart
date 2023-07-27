import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/component_widgets/button_circular_indicator.dart';

import '/app-state/app_state.dart';
import '/change_notifiers/app_state_notifier.dart';
import '../component_widgets/bottom_buttons.dart';

class NetworkErrorPage extends StatelessWidget {
  const NetworkErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NetworkError();
  }
}

class NetworkError extends StatefulWidget {
  const NetworkError({super.key});

  @override
  State<StatefulWidget> createState() {
    return NetworkErrorState();
  }
}

class NetworkErrorState extends State<NetworkError> {
  bool retrying = false;

  void checkAppState() async {
    var provider = Provider.of<AppStateNotifier>(context, listen: false);
    setState(() {
      retrying = true;
    });
    var newState = await AppState().getAppState();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      if (newState.state == 1) {
        provider.update(newState.user, 1);
        provider.updateAppUser();
      } else {
        setState(() {
          retrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      key: const Key('check-connection-error-page'),
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(244, 239, 255, 1.0),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,size: 35,),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Unable to connect to server. Retry or come back later if the issue persists.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black),
                ),
              ),
              (retrying)
                  ? const TaskPurpleButton(
                      onpressed: null,
                      buttonWidget: ButtonCircularIndicator(),
                      color: Colors.deepPurple)
                  : TaskPurpleButtonWithIcon(
                      onpressed: () {
                        checkAppState();
                      },
                      buttonWidget: const Text(
                        'retry',
                      ),
                      color: Colors.deepPurple,
                      iconData: Icons.refresh_rounded)
            ],
          ),
        ),
      ),
    );
  }
}
