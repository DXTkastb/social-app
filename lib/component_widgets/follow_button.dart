import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/change_notifiers/app_state_notifier.dart';

import '../data/models/external_user_data_model.dart';
import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class FollowButton extends StatefulWidget {
  const FollowButton({super.key});
  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late String accountName;
  late String searchAccountName;
  late bool following;
  bool processing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var provider =
    Provider.of<ExternalUserDataModel>(context, listen: false);
    var userAppProvider =
    Provider.of<AppStateNotifier>(context, listen: false);
    accountName = userAppProvider.user!.accountname;
    searchAccountName = provider.user.accountname!;
    following = provider.user.follow;
  }

  Widget getChild() {
    if (processing) {
      return const SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 1,
          ));
    }
    return (!following) ? const Text('follow') : const Text('unfollow');
  }


  @override
  Widget build(BuildContext context) {
    var provider =
    Provider.of<ExternalUserDataModel>(context, listen: false);
    return ElevatedButton(
      onPressed: () async {
        if(processing) return;
        provider.updateFollowing();
        setState(() {
          processing = true;
        });
        var port = ReceivePort();
        var output = port.first;
        MainIsolateEngine.engine.sendMessage({
          'operation': (following)?'UNFOLLOW_EXTERNAL_USER':'FOLLOW_EXTERNAL_USER',
          'data': {
            'follower' : accountName,
            'followee' : searchAccountName
          },
          'temp_port': port.sendPort
        });
        var list = (await output) as List;
        port.close();
        if (list.isEmpty) {

        } else {
          if(mounted){
            provider.updateFollowing();
            setState(() {
              processing = false;
              following = !following;
            });
          }
        }
      },
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Colors.deepPurple),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40)))),
      ),
      child: getChild(),
    );
  }
}
