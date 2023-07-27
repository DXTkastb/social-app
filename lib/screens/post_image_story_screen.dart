import 'package:flutter/material.dart';
import '/screens/upload_post_story_view/upload_post_view.dart';
import '/screens/upload_post_story_view/upload_story_view.dart';

class UploadPostStoryScreen extends StatelessWidget {

  /*
    type == 1 : Post story
    type == 2 : Post post
   */

  final int type;
  const UploadPostStoryScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(208, 184, 246, 1.0),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: (type == 2) ? const UploadPostView() : const UploadStoryView(),
      ),
    );
  }
}


