import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socio/change_notifiers/user_metadata_notifier.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/comment.dart';
import '/change_notifiers/app_state_notifier.dart';


class UserCommentWidget extends StatelessWidget {
  final Comment comment;


  const UserCommentWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: Color.fromRGBO(204, 189, 246, 1.0), width: 1)),
      ),
      width: double.infinity,
      child: Row(
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  'http://192.168.29.136:8080/profile-image/${comment.accountname}',
                  errorBuilder: (_,obh,trace){
                    return const Icon(Icons.person,color: Colors.deepPurple,);
                  },
                  height: 40,
                  width: 40,
                ),
              ),
            ),
          ),
          const VerticalDivider(
            width: 6,
          ),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                      text: comment.accountname,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                  TextSpan(
                      text: '\n ${comment.text}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserAddedCommentWidget extends StatelessWidget {
  final Comment comment;

  const UserAddedCommentWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: comment.userAddProgress,
        builder: (_, snapshot) {
          if(snapshot.hasError) {

          }
          if (snapshot.connectionState == ConnectionState.done) {
            var provider = Provider.of<UserMetaDataNotifier>(context,listen: false);
            return Container(
              padding: const EdgeInsets.only(bottom: 10, top: 10),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Color.fromRGBO(204, 189, 246, 1.0), width: 1)),
              ),
              width: double.infinity,
              child: Row(
                children: [
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: Center(
                      child: (snapshot.hasError)
                          ? const Icon(
                            Icons.error_outline,
                            color: Color.fromRGBO(147, 70, 70, 1.0),
                          )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(
                                'http://192.168.29.136:8080/profile-image/${provider.accountName}',
                                errorBuilder: (_,obh,trace){
                                  return const Icon(Icons.person,color: Colors.deepPurple,);
                                },
                                height: 40,
                                width: 40,
                              ),
                            ),
                    ),
                  ),
                  const VerticalDivider(
                    width: 6,
                  ),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: comment.accountname,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          TextSpan(
                              text: '\n ${comment.text}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Color.fromRGBO(204, 189, 246, 1.0), width: 1)),
            ),
            width: double.infinity,
            child: Row(
              children: [
                const SizedBox(
                  width: 45,
                  height: 45,
                  child: Center(
                    child: SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 6,
                ),
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black38),
                      children: <TextSpan>[
                        TextSpan(
                            text: comment.accountname,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        TextSpan(
                            text: '\n ${comment.text}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
