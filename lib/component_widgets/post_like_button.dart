import 'package:flutter/material.dart';
import 'package:socio/rsocket-engine/risolate_service/communication_data/communication_lib.dart';


class LikeIcon extends StatefulWidget {
  late TimelinePost userpost;

  LikeIcon({super.key, required this.userpost});

  @override
  State<LikeIcon> createState() => _LikeIconState();
}

class _LikeIconState extends State<LikeIcon> {
  @override
  Widget build(BuildContext context) {
    var post = widget.userpost;
    return GestureDetector(
        onTap: () {
          setState(() {
            post.liked = !post.liked;
          });
        },
        child: Icon(
          (post.liked) ? Icons.favorite : Icons.favorite_border,
          color: Colors.deepPurple,
          size: 28,
        ));
  }
}