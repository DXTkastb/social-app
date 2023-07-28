import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socio/shared-prefs/shared_pref_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '/routes/router.dart';
import '../change_notifiers/app_state_notifier.dart';
import '../change_notifiers/user_data_notifier.dart';
import '../change_notifiers/user_metadata_notifier.dart';
import '../data/user_details.dart';
import '../rest-service/rest_client.dart';

enum ChangeType { USERNAME, LINK, INFO }

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  BoxDecoration decoration() {
    return const BoxDecoration(
      color: Color.fromRGBO(207, 188, 255, 1.0),
      borderRadius: BorderRadius.all(Radius.circular(25)),
    );
  }

  TextStyle headingStyle() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(41, 37, 56, 1.0),
    );
  }

  Text subHeadingStyle(String subtext) {
    return Text(
      subtext,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color.fromRGBO(15, 15, 23, 1.0),
      ),
    );
  }

  Widget headingWidget(String headingText, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(padding: const EdgeInsets.all(5), child: Icon(icon)),
        const SizedBox(
          width: 3,
        ),
        Text(
          headingText,
          style: headingStyle(),
        )
      ],
    );
  }

  Widget onTapWidget(Widget widget, Function()? func) {
    return GestureDetector(
      onTap: func,
      child: widget,
    );
  }

  Widget getSubRowWidget(String text, IconData iconData) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: Icon(
              iconData,
              size: 18,
              color: const Color.fromRGBO(49, 44, 68, 1.0),
            )),
        subHeadingStyle(text)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 80,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(174, 138, 255, 1.0),
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25)),
            ),
            child: const Text(
              'Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(left: 20, right: 20),
            width: double.infinity,
            decoration: decoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headingWidget('ACCOUNT', Icons.account_circle_outlined),
                const Divider(
                  height: 10,
                  color: Colors.black,
                  indent: 10,
                  endIndent: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 8, bottom: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      onTapWidget(
                          getSubRowWidget(
                              'change password', Icons.password_rounded), () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) {
                              return const ChangePasswordAlertBox(
                                  key: Key('password-change'));
                            });
                      }),
                      const Divider(
                        height: 20,
                        thickness: 1,
                        indent: 0,
                        endIndent: 10,
                      ),
                      onTapWidget(
                          getSubRowWidget('change username',
                              Icons.drive_file_rename_outline_rounded), () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) {
                              return const ChangeDataAlertBox(
                                  key: Key('username-change'),
                                  changeType: ChangeType.USERNAME);
                            });
                      }),
                      const Divider(
                        height: 20,
                        thickness: 1,
                        indent: 0,
                        endIndent: 10,
                      ),
                      onTapWidget(
                          getSubRowWidget(
                              'change profile image', Icons.person_2_rounded),
                          () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) {
                              return const ImageChangeAlertBox();
                            });
                      }),
                      const Divider(
                        height: 20,
                        thickness: 1,
                        indent: 0,
                        endIndent: 10,
                      ),
                      onTapWidget(
                          getSubRowWidget('change link', Icons.link_rounded),
                          () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) {
                              return const ChangeDataAlertBox(
                                  key: Key('username-change'),
                                  changeType: ChangeType.LINK);
                            });
                      }),
                      const Divider(
                        height: 20,
                        thickness: 1,
                        indent: 0,
                        endIndent: 10,
                      ),
                      onTapWidget(
                          getSubRowWidget('change info', Icons.dataset_rounded),
                          () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) {
                              return const ChangeDataAlertBox(
                                  key: Key('username-change'),
                                  changeType: ChangeType.INFO);
                            });
                      }),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          onTapWidget(
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(left: 20, right: 20),
                width: double.infinity,
                decoration: decoration(),
                child: headingWidget('HELP', Icons.help_outline_outlined),
              ), () {
            launchUrl(Uri.parse('https://github.com/DXTkastb'));
          }),
          const SizedBox(
            height: 10,
          ),
          onTapWidget(
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(left: 20, right: 20),
                width: double.infinity,
                decoration: decoration(),
                child: headingWidget('ABOUT', Icons.info_outline_rounded),
              ), () {
            Navigator.of(context).pushNamed(AppRoutePaths.aboutRoute);
          }),
          const Expanded(child: SizedBox()),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            width: double.infinity,
            alignment: Alignment.center,
            //   color: Colors.deepPurpleAccent.shade100,
            child: ElevatedButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.only(
                      top: 15, left: 22, right: 22, bottom: 15)),
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25))))),
              onPressed: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (ctx) {
                      return const LogoutAlertBox();
                    });
              },
              child: const Text('logout'),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      )),
    );
  }
}

class ChangePasswordAlertBox extends StatefulWidget {
  const ChangePasswordAlertBox({super.key});

  @override
  State<ChangePasswordAlertBox> createState() => _ChangePasswordAlertBoxState();
}

class _ChangePasswordAlertBoxState extends State<ChangePasswordAlertBox> {
  bool showPassword = true;
  bool processing = false;
  bool updatedStatus = false;
  TextEditingController textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ButtonStyle buttonstyle(bool main) {
    return ButtonStyle(
        backgroundColor:
            MaterialStatePropertyAll((main) ? Colors.deepPurple : Colors.black),
        shape: const MaterialStatePropertyAll(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24))),
        ));
  }

  Future<int> changePassword() async {
    return RestClient.changePassword(
      textEditingController.value.text,
      Provider.of<UserMetaDataNotifier>(context, listen: false).accountName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: const Color.fromRGBO(215, 209, 238, 1.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24))),
      contentPadding:
          const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 12),
      actionsPadding:
          const EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 12),
      content: Form(
          onWillPop: () async {
            if (updatedStatus) return true;
            if (!processing) return false;
            return false;
          },
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                obscureText: showPassword,
                validator: (value) {
                  if (value != null && value.length < 8) {
                    return "Minimum 8 characters allowed";
                  }
                  return null;
                },
                controller: textEditingController,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                      activeColor: Colors.deepPurple,
                      activeTrackColor:
                          const Color.fromRGBO(157, 138, 245, 1.0),
                      value: !showPassword,
                      onChanged: (val) {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      }),
                  const Text('show password'),
                ],
              )
            ],
          )),
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                    (updatedStatus) ? Colors.green : Colors.deepPurple),
                shape: const MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                )),
            onPressed: () async {
              if (processing) return;
              if (_formKey.currentState!.validate()) {
                setState(() {
                  processing = true;
                });
                int val = await changePassword();
                if (val == 500 && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          const Text('some error occured please try later')));
                  Navigator.of(context).pop();
                  return;
                }
                if (mounted) {
                  setState(() {
                    //   processing = false;
                    updatedStatus = true;
                  });
                }
                await Future.delayed(const Duration(seconds: 1));
                if (mounted && updatedStatus) Navigator.of(context).pop();
              }
            },
            child: (processing && !updatedStatus)
                ? const SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                        strokeWidth: 1, color: Colors.white),
                  )
                : Text((updatedStatus) ? 'updated' : 'update')),
        ElevatedButton(
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.black),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                )),
            onPressed: () {
              if (processing) return;
              Navigator.of(context).pop();
            },
            child: const Text('cancel')),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }
}

class LogoutAlertBox extends StatefulWidget {
  const LogoutAlertBox({super.key});

  @override
  State<LogoutAlertBox> createState() => _LogoutAlertBoxState();
}

class _LogoutAlertBoxState extends State<LogoutAlertBox> {
  bool inprocess = false;

  void logout() async {
    if (inprocess) return;
    setState(() {
      inprocess = true;
    });
    await FirebaseMessaging.instance.deleteToken();
    await SharedPrefService.deleteAuthKey();
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      var appStateProvider =
          Provider.of<AppStateNotifier>(context, listen: false);
      appStateProvider.fireLogoutState();
    }
    // if (mounted) {
    //   Navigator.of(context).pushNamedAndRemoveUntil(
    //       AppRoutePaths.loginPageRoute, (route) => false);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !inprocess;
      },
      child: AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        backgroundColor: const Color.fromRGBO(215, 209, 238, 1.0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24))),
        contentPadding:
            const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 12),
        actionsPadding:
            const EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 12),
        content: const Text(
          'Do you want to log out?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (inprocess) return;
              Navigator.of(context).pop();
            },
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.deepPurple),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                )),
            child: const Text('cancel'),
          ),
          ElevatedButton(
            onPressed: logout,
            style: const ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(Color.fromRGBO(65, 18, 18, 1.0)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                )),
            child: (!inprocess)
                ? const Text('logout')
                : const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color: Colors.white,
                    ),
                  ),
          )
        ],
      ),
    );
  }
}

class ImageChangeAlertBox extends StatefulWidget {
  const ImageChangeAlertBox({super.key});

  @override
  State<ImageChangeAlertBox> createState() => _ImageChangeAlertBoxState();
}

class _ImageChangeAlertBoxState extends State<ImageChangeAlertBox> {
  late final ImagePicker _picker;
  XFile? profile_image;
  bool uploadState = false;
  bool uploadStatus = false;

  @override
  void initState() {
    _picker = ImagePicker();
    super.initState();
  }

  Future<String> changeProfileImage(String accountName) async {
    return RestClient.changeDp(accountName, profile_image!.path);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (uploadStatus) return true;
        if (!uploadState) return false;
        return false;
      },
      child: AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        backgroundColor: const Color.fromRGBO(215, 209, 238, 1.0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24))),
        contentPadding:
            const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 12),
        actionsPadding:
            const EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 12),
        content: Container(
          height: 150,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () async {
              if (uploadState) return;
              final XFile? image =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (mounted) {
                setState(() {
                  profile_image = image;
                });
              }
            },
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                // color: const Color.fromRGBO(128, 250, 250, 1.0),
                border: Border.all(width: 17, color: Colors.black),
                borderRadius: BorderRadius.circular(80),
              ),
              child: (profile_image == null)
                  ? const SizedBox()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(80.0),
                      child: FadeInImage(
                        key: Key(profile_image!.path),
                        placeholder: const AssetImage('asset/load.gif'),
                        image: FileImage(File(profile_image!.path)),
                        fit: BoxFit.fill,
                        placeholderFit: BoxFit.scaleDown,
                      ),
                    ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      (uploadStatus) ? Colors.green : Colors.deepPurple),
                  shape: const MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24))),
                  )),
              onPressed: () async {
                if (uploadState || profile_image == null) return;

                setState(() {
                  uploadState = true;
                });
                var appStateProvider =
                    Provider.of<UserMetaDataNotifier>(context, listen: false);
                String num =
                    await changeProfileImage(appStateProvider.accountName);
                if (mounted) {
                  if (num.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('some error occurred.please try later')));
                    Navigator.of(context).pop();
                    return;
                  }
                  setState(() {
                    uploadStatus = true;
                  });
                  await Future.delayed(const Duration(milliseconds: 400));
                  if (uploadStatus && mounted) {
                    Provider.of<UserDataNotifier>(context, listen: false)
                        .refreshData(appStateProvider.accountName, 2, num);
                    Navigator.of(context).pop();
                  }
                }
              },
              child: (!uploadState || uploadStatus)
                  ? Text((uploadStatus) ? 'uploaded' : 'upload')
                  : const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 1,
                      ))),
          ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Color.fromRGBO(0, 0, 0, 1.0)),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24))),
                  )),
              onPressed: () {
                if (uploadState) return;
                Navigator.of(context).pop();
              },
              child: const Text('cancel')),
        ],
      ),
    );
  }
}

class ChangeDataAlertBox extends StatefulWidget {
  final ChangeType changeType;

  const ChangeDataAlertBox({super.key, required this.changeType});

  @override
  State<ChangeDataAlertBox> createState() => _ChangeDataAlertBoxState();
}

class _ChangeDataAlertBoxState extends State<ChangeDataAlertBox> {
  bool processing = false;
  bool updatedStatus = false;
  int allowedLength = 0;
  late TextEditingController textEditingController;
  final _formKey = GlobalKey<FormState>();
  late final String url;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.changeType == ChangeType.USERNAME) {
      url = 'username update url';
      allowedLength = 20;
    } else if (widget.changeType == ChangeType.INFO) {
      url = 'link update url';
      allowedLength = 100;
    } else if (widget.changeType == ChangeType.LINK) {
      url = 'info update url';
      allowedLength = 40;
    }
  }

  ButtonStyle buttonstyle(bool main) {
    return ButtonStyle(
        backgroundColor:
            MaterialStatePropertyAll((main) ? Colors.deepPurple : Colors.black),
        shape: const MaterialStatePropertyAll(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24))),
        ));
  }

  Future<Map> updateValue() async {
    int index = -1;

    if (widget.changeType == ChangeType.USERNAME) {
      index = 1;
    } else if (widget.changeType == ChangeType.LINK) {
      index = 3;
    } else if (widget.changeType == ChangeType.INFO) {
      index = 4;
    }
    var appStateProvider =
        Provider.of<UserMetaDataNotifier>(context, listen: false);
    return Provider.of<UserDataNotifier>(context, listen: false).refreshData(
        appStateProvider.accountName, index, textEditingController.value.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: const Color.fromRGBO(215, 209, 238, 1.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24))),
      contentPadding:
          const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 12),
      actionsPadding:
          const EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 12),
      content: Form(
          onWillPop: () async {
            if (updatedStatus) return true;
            return !processing;
          },
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                maxLines: 2,
                maxLength: allowedLength,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'field is empty!';
                  }
                  if (widget.changeType == ChangeType.LINK) {
                    if (!(value.contains(RegExp(r"www.[A-Za-z]+.com")))) {
                      return 'only www.[A-Za-z].com allowed';
                    }
                    // if(value.length>40)
                    //   return 'link length exceeded: 40 allowed';
                  }
                  if (widget.changeType == ChangeType.INFO) {
                    if (!(value.contains(RegExp(r"^([A-Za-z]|\d)+$")))) {
                      return 'only www.[A-Za-z].com allowed';
                    }
                    // if(value.length>100)
                    //   return 'link length exceeded: 100 allowed';
                  }
                  if (widget.changeType == ChangeType.USERNAME) {
                    if (!value.contains(RegExp(r"^([A-Za-z]|\d)+$"))) {
                      return "Only alphabets and numbers allowed!";
                    }
                    // if(value.length>20)
                    //   return 'username length exceeded: 20 allowed';
                  }
                  return null;
                },
                controller: textEditingController,
              ),
            ],
          )),
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                    (updatedStatus) ? Colors.green : Colors.deepPurple),
                shape: const MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                )),
            onPressed: () async {
              if (processing) return;
              if (_formKey.currentState!.validate()) {
                setState(() {
                  processing = true;
                });
                Map map = await updateValue();
                if (map.isEmpty && mounted) {
                  // some error occured!!
                  setState(() {
                    processing = false;
                    updatedStatus = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('some error occurred.please try later')));
                  Navigator.of(context).pop();
                  return;
                }
                if (mounted) {
                  setState(() {
                    //   processing = false;
                    updatedStatus = true;
                  });
                }
                await Future.delayed(const Duration(seconds: 1));
                if (mounted && updatedStatus) Navigator.of(context).pop();
              }
            },
            child: (processing && !updatedStatus)
                ? const SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                        strokeWidth: 1, color: Colors.white),
                  )
                : Text((updatedStatus) ? 'updated' : 'update')),
        ElevatedButton(
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.black),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                )),
            onPressed: () {
              if (processing) return;
              Navigator.of(context).pop();
            },
            child: const Text('cancel')),
      ],
    );
  }
}
