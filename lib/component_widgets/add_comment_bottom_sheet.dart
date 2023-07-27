import 'dart:isolate';

import 'package:flutter/material.dart';

import '../rsocket-engine/risolate_service/main_isolate_engine.dart';

class AddCommentSheet extends StatefulWidget {
  final String accountname;
  final String postCreatorName;
  final int postid;

  const AddCommentSheet(
      {super.key,
      required this.accountname,
      required this.postCreatorName,
      required this.postid});

  @override
  State<AddCommentSheet> createState() => _AddCommentSheetState();
}

class _AddCommentSheetState extends State<AddCommentSheet> {
  final _textFieldKey = GlobalKey<FormFieldState>();

  @override
  void dispose() {
    super.dispose();
  }

  Future addCommentFuture(String accountname, String postCreatorName,
      String text, int postid) async {
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'POST_COMMENT',
      'data': {
        'onpostid': postid,
        'text': text,
        'postCreatorName': postCreatorName,
        'accountname': accountname
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();
    if (list.isEmpty) {
      throw Exception('rsocket connection error');
    } else {
      var x = list[0] as int;
      if(x!=201) {
        throw Exception('rsocket connection error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: 150,
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
                child: TextFormField(
                  key: _textFieldKey,
                  maxLength: 100,
                  minLines: 1,
                  maxLines: 2,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'comment is empty';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      var textValue = _textFieldKey.currentState!.value;
                      if (textValue != null && textValue!.isNotEmpty) {
                        // add comment

                        Navigator.of(context)
                            .pop([textValue, addCommentFuture(widget.accountname,widget.postCreatorName,textValue,widget.postid)]);
                      }
                    },
                    style: const ButtonStyle(
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40)))),
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.deepPurple)),
                    child: const Text('comment'),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: const ButtonStyle(
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)))),
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.black)),
                      child: const Text('cancel')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
