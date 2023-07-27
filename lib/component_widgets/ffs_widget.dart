import 'dart:isolate';

import 'package:flutter/material.dart';

import '../rsocket-engine/risolate_service/main_isolate_engine.dart';
import 'general_profile_image.dart';
import 'loda_more_list_widget.dart';

class FfsWidget extends StatefulWidget {
  /*
    type 1 : fetch followers
    type 2 : fetch followees
   */

  final int type;
  final String accountName;

  const FfsWidget({super.key, required this.type, required this.accountName});

  @override
  State<FfsWidget> createState() => _FfsWidgetState();
}

class _FfsWidgetState extends State<FfsWidget> {
  ScrollController scrollController = ScrollController();
  late int queryNum;
  final ReceivePort port = ReceivePort();
  late Stream stream;
  List<String> accounts = [];
  late Future loadFuture;
  bool canLoadMore = true;
  bool loadingMore = false;

  @override
  void initState() {
    super.initState();
    queryNum = 1;
    stream = port.asBroadcastStream();
    loadFuture = futureGenerator();
    newLoadListener();
  }

  Future futureGenerator() {
    return stream.first.then((value) {
      if(mounted){
        value = value as List;
        if (value.isEmpty) {
          return 0;
        }
        Map data = value[0];
        List<String> loadedAccounts = data['data'];
        accounts.addAll(loadedAccounts);
        if (loadedAccounts.isEmpty || loadedAccounts.length < 50) {
          canLoadMore = false;
        }
        return 1;
      }
    });
  }

  void newLoadListener() {
    stream.listen((event) {
      if (mounted) {
        if (loadingMore) {
          event = event as List;
          if (event.isEmpty) {

          }
          Map data = event[0];
          List<String> loadedAccounts = data['data'];
          if (loadedAccounts.isEmpty || loadedAccounts.length < 50) {
            canLoadMore = false;
          }
          setState(() {
            accounts.addAll(loadedAccounts);
            loadingMore = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    port.close();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MainIsolateEngine.engine.sendMessage({
      'operation': (widget.type == 1) ? 'FETCH_FOLLOWERS' : 'FETCH_FOLLOWING',
      'data': {'accountName': widget.accountName, 'queryNumber': queryNum},
      'temp_port': port.sendPort
    });
  }

  void loadMoreResult() {
    if (canLoadMore && !loadingMore) {
      loadingMore = true;
      MainIsolateEngine.engine.sendMessage({
        'operation': (widget.type == 1) ? 'FETCH_FOLLOWERS' : 'FETCH_FOLLOWING',
        'data': {
          'accountName': widget.accountName,
          'lastAccountName': accounts.last
        },
        'temp_port': port.sendPort
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Column(
        children: [
          Text((widget.type == 1) ? 'Followers' : 'Following'),
          Expanded(
              child: FutureBuilder(
            future: loadFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == 0) {
                  return const Center(
                    child: Text('some error occured!'),
                  );
                }
                int length = accounts.length;

                if(length == 0){
                  return Center(
                    child: Text(
                        (widget.type == 1)?
                        'No followers!':
                        'No following!'
                    ),
                  );
                }
                return NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.extentAfter < 30) {
                      loadMoreResult();
                    }
                    return true;
                  },
                  child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      controller: scrollController,
                      prototypeItem: const SizedBox(
                        height: 50,
                      ),
                      itemCount: (canLoadMore) ? (length + 1) : length,
                      itemBuilder: (ctx, index) {
                        Widget child;

                        if (index == length) {
                          child = const LoadMoreWidgetList();
                        } else {
                          child = GestureDetector(
                              onTap: () {
                                // push to external user view
                              },
                              child: Row(
                                children: [
                                  GeneralAccountImage(accountName: accounts[index], size: 40,),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    accounts[index],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ));
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            height: 40,
                            child: child,
                          ),
                        );
                      }),
                );
              }
              return const Center(
                child: SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                    )),
              );
            },
          ))
        ],
      ),
    );
  }
}
