import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socio/change_notifiers/app_state_notifier.dart';

import '/component_widgets/bottom_buttons.dart';
import '/data/models/upload_story_model.dart';
import '../../change_notifiers/user_personal_story.dart';
import '../../rsocket-engine/risolate_service/communication_data/story.dart';
import '../../rsocket-engine/risolate_service/main_isolate_engine.dart';

class UploadStoryView extends StatelessWidget {
  const UploadStoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<PostStoryModel>(
      create: (_) => PostStoryModel(),
      dispose: (_, val) => val.dispose(),
      builder: (_, wid) {
        return Column(
          children: [
            Container(
              color: const Color.fromRGBO(174, 138, 255, 1.0),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 10, right: 20),
                child: Row(
                  children: const [
                    CustomSwitcher(),
                    Text(
                      'memory',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Expanded(child: SizedBox()),
                    MemoryInfo(),
                  ],
                ),
              ),
            ),
            const Expanded(child: AddStoryContainer()),
            const Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: UploadStoryButtonRow())
          ],
        );
      },
    );
  }
}

class CustomSwitcher extends StatefulWidget {
  const CustomSwitcher({super.key});

  @override
  State<CustomSwitcher> createState() => _CustomSwitcherState();
}

class _CustomSwitcherState extends State<CustomSwitcher> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PostStoryModel>(context, listen: false);

    return Switch(
        inactiveTrackColor: const Color.fromRGBO(87, 59, 129, 1.0),
        inactiveThumbColor: const Color.fromRGBO(222, 204, 255, 1.0),
        activeColor: const Color.fromRGBO(97, 30, 155, 1.0),
        activeTrackColor: const Color.fromRGBO(104, 65, 187, 1.0),
        value: provider.memory,
        onChanged: (val) {
          setState(() {
            provider.switcher();
          });
        });
  }
}

class MemoryInfo extends StatelessWidget {
  const MemoryInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                content: const Text(
                  'enabling memory saves your story, which can be viewed later in user profile',
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.center,
                icon: const Icon(
                  Icons.info_outline_rounded,
                  size: 45,
                  color: Colors.green,
                ),
                actions: [
                  OkButton(onpressed: () {
                    Navigator.of(dialogContext).pop();
                  })
                ],
              );
            });
      },
      child: const Icon(Icons.info_outline_rounded),
    );
  }
}

class UploadStoryButtonRow extends StatefulWidget {
  const UploadStoryButtonRow({super.key});

  @override
  State<UploadStoryButtonRow> createState() => _UploadStoryButtonRowState();
}

class _UploadStoryButtonRowState extends State<UploadStoryButtonRow> {
  bool uploading = false;
  bool uploadStatus = false;

  void onpressed() async {
    var postStoryModelProvider =
        Provider.of<PostStoryModel>(context, listen: false);
    var appStateProvider =
        Provider.of<AppStateNotifier>(context, listen: false);
    if (uploadStatus) return;

    setState(() {
      uploading = true;
    });

    // await Future.delayed(const Duration(seconds: 2)); // implicate upload story
    var port = ReceivePort();
    var output = port.first;
    MainIsolateEngine.engine.sendMessage({
      'operation': 'ADD_NEW_STORY',
      'data': {
        'accountName': appStateProvider.user!.accountname,
        'filePath': postStoryModelProvider.file!.path
      },
      'temp_port': port.sendPort
    });
    var list = (await output) as List;
    port.close();

    if (list.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Connection Error. Please try later.'),
          duration: Duration(seconds: 2),
        ));
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop(uploadStatus);
          }
        });
      }
    } else {
      Story newUploadStory = list[0];
      if (mounted) {
        if (newUploadStory.storyid != -1) {
          Provider.of<UserPersonalStoryNotifier>(context, listen: false)
              .addUploadedStory(newUploadStory);

          setState(() {
            uploading = false;
            uploadStatus = true;
          });
        }
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (uploadStatus) return true;
        return !uploading;
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          (uploading)
              ? TaskPurpleButton(
                  buttonWidget: const SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  color: Colors.deepPurple,
                  onpressed: () {},
                )
              : TaskPurpleButton(
                  buttonWidget: (uploadStatus)
                      ? const Text('uploaded')
                      : const Text('upload'),
                  color: (uploadStatus) ? Colors.green : Colors.deepPurple,
                  onpressed: onpressed,
                ),
          const SizedBox(
            width: 10,
          ),
          CancelButton(onpressed: () {
            if (uploading) return;
            Navigator.of(context).pop();
          }),
        ],
      ),
    );
  }
}

class AddStoryContainer extends StatefulWidget {
  const AddStoryContainer({super.key});

  @override
  State<AddStoryContainer> createState() => _AddStoryContainerState();
}

class _AddStoryContainerState extends State<AddStoryContainer> {
  late final ImagePicker _picker;
  late final PostStoryModel model;

  @override
  void initState() {
    _picker = ImagePicker();
    super.initState();
  }

  void onpressed() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (mounted && image != null) {
      setState(() {
        model.file = image;
      });
    }
  }

  Widget imageAddButton(bool onStack) {
    if (onStack) {
      return ElevatedButton.icon(
          onPressed: onpressed,
          icon: const Icon(Icons.refresh_outlined),
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.deepPurple),
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ))),
          label: const Text('change'));
    }
    return Ink(
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
          padding: const EdgeInsets.all(30),
          iconSize: 45,
          onPressed: onpressed,
          icon: const Icon(Icons.add_photo_alternate_outlined)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (model.file == null)
        ? Center(child: imageAddButton(false))
        : Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                decoration:
                    const BoxDecoration(color: Colors.black, boxShadow: [
                  BoxShadow(
                      color: Colors.black54,
                      spreadRadius: 7.5,
                      blurRadius: 15,
                      offset: Offset(0, 5))
                ]),
                alignment: Alignment.center,
                margin: const EdgeInsets.all(25),
                child: FadeInImage(
                  key: Key(model.file!.path),
                  placeholder: const AssetImage('asset/load.gif'),
                  image: FileImage(File(model.file!.path)),
                  fit: BoxFit.fill,
                ),
              ),
              imageAddButton(true),
            ],
          );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    model = Provider.of<PostStoryModel>(context, listen: false);
  }
}
