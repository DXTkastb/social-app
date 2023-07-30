import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socio/component_widgets/button_circular_indicator.dart';

import '../../change_notifiers/user_metadata_notifier.dart';
import '/change_notifiers/app_state_notifier.dart';
import '/change_notifiers/user_data_notifier.dart';
import '/change_notifiers/user_personal_posts_set_notifier.dart';
import '/component_widgets/bottom_buttons.dart';
import '/component_widgets/general_profile_image.dart';
import '/data/models/upload_post_model.dart';
import '../../change_notifiers/timeline_posts_set_notifier.dart';
import '../../rsocket-engine/risolate_service/communication_data/post.dart';
import '../../rsocket-engine/risolate_service/main_isolate_engine.dart';

class UploadPostView extends StatelessWidget {
  const UploadPostView({super.key});

  @override
  Widget build(BuildContext context) {
    var userDataProvider1 = Provider.of<UserMetaDataNotifier>(context, listen: false);
    var userDataProvider2 = Provider.of<UserDataNotifier>(context, listen: false);
    return Provider<PostUploadModel>(
      create: (ctx) => PostUploadModel(),
      dispose: (ctx, value) => value.dispose(),
      child: LayoutBuilder(builder: (layoutContext, constraints) {
        return Column(
          children: [
            const ImageViewer(),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GeneralAccountImage(accountName: userDataProvider1.accountName, size: 55),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(userDataProvider2.username)),
                  ),
                  const Expanded(child: SizedBox()),
                  // const Icon(
                  //   Icons.location_on_rounded,
                  //   size: 30,
                  // )
                ],
              ),
            ),
            const Expanded(child: UploadPostForm()),
          ],
        );
      }),
    );
  }
}

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final ImagePicker _picker = ImagePicker();
  XFile? postImage;

  void addNewImage() async {
    var provider = Provider.of<PostUploadModel>(context,listen: false);
    postImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (mounted && postImage != null) {
      setState(() {
        provider.xfile = postImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(174, 138, 255, 1.0),
      height: 250,
      width: double.infinity,
      child: (postImage == null)
          ? Material(
              color: Colors.transparent,
              child: Center(
                child: Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                      splashColor: Colors.deepPurple,
                      color: Colors.black,
                      focusColor: Colors.deepPurple,
                      highlightColor: Colors.deepPurple,
                      hoverColor: Colors.deepPurple,
                      splashRadius: 70,
                      padding: const EdgeInsets.all(30),
                      iconSize: 45,
                      onPressed: () {
                        addNewImage();
                      },
                      icon: const Icon(Icons.add_photo_alternate_outlined)),
                ),
              ),
            )
          : Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ColoredBox(
                  color: Colors.black,
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: FadeInImage(
                      key: Key(postImage!.path),
                      placeholder: const AssetImage('asset/load.gif'),
                      image: FileImage(File(postImage!.path)),
                      fit: BoxFit.contain,
                      placeholderFit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                Positioned(
                    bottom: -20,
                    child: TaskPurpleButtonWithIcon(
                      onpressed: () {
                        addNewImage();
                      },
                      buttonWidget: const Text('change'),
                      color: Colors.deepPurple,
                      iconData: Icons.refresh_outlined,
                    ))
              ],
            ),
    );
  }
}

class UploadPostForm extends StatefulWidget {
  const UploadPostForm({super.key});

  @override
  State<UploadPostForm> createState() => _UploadPostFormState();
}

class _UploadPostFormState extends State<UploadPostForm> {
  bool uploading = false;
  bool uploadStatus = false;
  late final TextEditingController textEditingController;
 // final _formKey = GlobalKey<FormFieldState>();

  void onpressedUpload() async {
    if (uploadStatus) return;
    var provider = Provider.of<PostUploadModel>(context, listen: false);
    var appStateProvider =
        Provider.of<AppStateNotifier>(context, listen: false);
    if (provider.xfile == null) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                content: const Text(
                  'please upload image!',
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.center,
                icon: const Icon(
                  Icons.error_outline,
                  size: 45,
                  color: Color.fromRGBO(194, 81, 96, 1.0),
                ),
                actions: [
                  OkButton(onpressed: () {
                    Navigator.of(ctx).pop();
                  })
                ],
              ));
      return;
    }
    setState(() {
      uploading = true;
    });

    // await Future.delayed(const Duration(seconds: 3));
    // simulates rsocket upload call

    var port = ReceivePort();
    var output = port.first;

    MainIsolateEngine.engine.sendMessage({
      'operation': 'ADD_NEW_POST',
      'data': {
        'accountName': appStateProvider.user.accountname,
        'caption': textEditingController.value.text,
        'filePath': provider.xfile!.path
      },
      'temp_port': port.sendPort
    });

    var list = (await output) as List;
    port.close();
    if (list.isEmpty) {
      if (mounted) {
        // some rsocket connection error occured
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Connection Error. Please try later.'),
          duration: Duration(seconds: 2),
        ));
        setState(() {
          uploading = false;
          uploadStatus = true;
        });
        if (mounted) {
          Navigator.of(context).pop(uploadStatus);
        }
      }
    } else {
      if (mounted) {
        Post newUploadedPost = list[0];
        if (newUploadedPost.postid != -1) {
          Provider.of<TimelinePostsNotifier>(context, listen: false)
              .uploadedNewPost();
          Provider.of<UserPersonalPostSet>(context, listen: false)
              .uploadedNewPost(newUploadedPost);
          Provider.of<UserMetaDataNotifier>(context, listen: false).refreshMetaData();
          setState(() {
            uploading = false;
            uploadStatus = true;
          });

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pop(uploadStatus);
          }
        }
        else{
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Server Error. Please try later.'),
            duration: Duration(seconds: 2),
          ));
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pop(uploadStatus);
          }
        }

      }
    }
  }

  void onpressedCancel() {
    if (uploading) return;
    Navigator.of(context).pop(uploadStatus);
  }


  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (uploadStatus) return true;
        return !uploading;
      },
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 0, left: 30, right: 30),
              child: TextFormField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  labelText: 'caption',
                ),
                maxLines: 4,
              )),
          // Padding(         // for geolocation
          //     padding: const EdgeInsets.all(20),
          //     child: TextFormField()),
          Expanded(
            child: Container(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              (uploading)
                  ? TaskPurpleButton(
                      buttonWidget: const ButtonCircularIndicator(),
                      color: Colors.deepPurple,
                      onpressed: () {},
                    )
                  : TaskPurpleButton(
                      buttonWidget: (uploadStatus)
                          ? const Text('uploaded')
                          : const Text('upload'),
                      color: (uploadStatus) ? Colors.green : Colors.deepPurple,
                      onpressed: onpressedUpload,
                    ),
              const SizedBox(
                width: 10,
              ),
              CancelButton(onpressed: onpressedCancel),
              const SizedBox(
                width: 20,
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
   }
}
