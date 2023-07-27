import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/component_widgets/bottom_buttons.dart';
import 'package:socio/component_widgets/normal_circular_indicator.dart';

import '/screens/parent_ui_screen.dart';
import '../change_notifiers/app_state_notifier.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class InitializationUIView extends StatefulWidget {
  const InitializationUIView({super.key});

  @override
  State<InitializationUIView> createState() => _InitializationUIViewState();
}

class _InitializationUIViewState extends State<InitializationUIView> {
  bool disconnectedState = false;
  late StreamSubscription streamSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    streamSubscription =
        MainIsolateEngine.engine.rNetworkConnectionErrorStream.listen((event) {
      if (event == 'CONNECTION_LOST' && mounted) {
        if (disconnectedState) return;
        disconnectedState = true;
        showModalBottomSheet(
            enableDrag: false,
            useSafeArea: true,
            isDismissible: false,
            context: context,
            builder: (ctx) {
              return const RetryRsocketBottomSheet();
            });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false, // BETA
      backgroundColor: Color.fromRGBO(193, 172, 229, 1.0),
      body: SafeArea(child: ParentUiScreen()),
    );
  }
}

class RetryRsocketBottomSheet extends StatefulWidget {
  const RetryRsocketBottomSheet({super.key});

  @override
  State<RetryRsocketBottomSheet> createState() =>
      _RetryRsocketBottomSheetState();
}

class _RetryRsocketBottomSheetState extends State<RetryRsocketBottomSheet> {
  bool retrying = false;

  void tryRefresh() async {
    var appStateProvider =
        Provider.of<AppStateNotifier>(context, listen: false);
    setState(() {
      retrying = !retrying;
    });
     appStateProvider.initializeRConnect();
    // await Future.delayed(const Duration(seconds: 1));
     if(mounted) {
      var connectionState = await appStateProvider.rConnect;
      if (connectionState == 1) {
        if (mounted) {
          appStateProvider.refreshConnection();
        }
      } else {
        if (mounted) {
          setState(() {
            retrying = !retrying;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (retrying) return false;
        return true;
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.black,
          height: 200,
          child: Column(
            children: [
              const Padding(
                  padding: EdgeInsets.all(20),
                  child: Icon(
                    Icons.signal_cellular_connected_no_internet_0_bar_rounded,
                    color: Colors.white,
                  )),
              const Text(
                'Lost connection. Check your internet connection and retry.',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const Expanded(child: SizedBox()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (retrying)
                      ? const NormalCircularIndicator()
                      : const SizedBox(),
                  TaskPurpleButtonWithIcon(
                      onpressed: (retrying) ? null : tryRefresh,
                      buttonWidget: const Text('retry'),
                      color: Colors.deepPurple,
                      iconData: Icons.refresh),
                ],
              )
            ],
          )),
    );
  }
}
