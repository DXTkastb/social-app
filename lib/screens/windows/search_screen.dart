import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/component_widgets/general_profile_image.dart';

import '../../change_notifiers/user_metadata_notifier.dart';
import '/change_notifiers/user_search_notifier.dart';
import '/routes/router.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return ChangeNotifierProvider(
        create: (_) => UserSearchNotifier(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 12, left: 55, right: 55),
              width: constraints.maxWidth,
              height: 80,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(174, 138, 255, 1.0),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25)),
              ),
              child: const SearchBox(),
            ),
            const Expanded(child: SearchBoxResultsList())
          ],
        ),
      );
    });
  }
}

class SearchBox extends StatefulWidget {
  const SearchBox({super.key});

  @override
  State<SearchBox> createState() => _SearchBoxState();
}



class _SearchBoxState extends State<SearchBox> {
  bool hasError = false;
  bool getError(String text) {
   return (text.contains(RegExp(r'^[a-zA-Z]+$')));
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Form(
            child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                height: 80,
                width: constraints.maxWidth,
                child: TextFormField(
                  autofocus: false,
                  onChanged: (text) {
                    if(text.isEmpty) {
                      setState(() {
                        hasError = false;
                      });
                    }
                    else if(getError(text)) {
                      setState(() {
                        hasError = false;
                      });
                      Provider.of<UserSearchNotifier>(context, listen: false)
                          .newInput(text);
                    }
                    else {
                      setState(() {
                        hasError = true;
                      });
                    }
                  },
                  cursorColor: const Color.fromRGBO(79, 33, 176, 1.0),
                  decoration: InputDecoration(
                    errorText: (hasError)? 'Only letters allowed. No special character':null,
                    suffixIconColor: const Color.fromRGBO(79, 33, 176, 1.0),
                    suffixIcon: const Icon(Icons.search),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(79, 33, 176, 1.0), width: 2)),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(36, 15, 86, 1.0), width: 2)),
                  ),
                )),
          ],
        ));
      },
    );
  }
}

class SearchBoxResultsList extends StatelessWidget {
  const SearchBoxResultsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSearchNotifier>(builder: (_, userSearch, widget) {
      return FutureBuilder(
          future: userSearch.search,
          builder: (ctx, snapshot) {
            if(snapshot.hasError) return const Center(child: Text('some error error, please try later.'),);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data;
              if (data != null || data!.isEmpty) {
                return NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (notification) {
                    notification.disallowIndicator();
                    return false;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                        bottom: 80, top: 20, left: 20, right: 20),
                    key: const Key('search-result-list'),
                    itemCount: data.length,
                    itemBuilder: (ctx2, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(ctx2).pushNamed(
                              AppRoutePaths.externalUserViewRoute,
                              arguments: data[index]).then((value) {
                                if(value!=null && ctx.mounted){
                                  Provider.of<UserMetaDataNotifier>(ctx, listen: false).refreshMetaData();
                                }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              //color: const Color.fromRGBO(145, 136, 208, 1.0),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GeneralAccountImage(
                                    accountName: data[index].accountname!,
                                    size: 40,
                                    fromResource: null,
                                  )),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                data[index].accountname!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(
                        indent: 15,
                        endIndent: 15,
                        height: 12,
                        color: Colors.blueGrey,
                      );
                    },
                  ),
                );
              } else {
                return const Align(
                    alignment: Alignment.topCenter,
                    child: Text('user not found'));
              }
            }
            return const Icon(Icons.person);
          });
    });
  }
}
