import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socio/component_widgets/bottom_buttons.dart';
import 'package:socio/component_widgets/button_circular_indicator.dart';
import 'package:socio/login-signup/login_signup_styles.dart';

import '../data/user_details.dart';
import '/change_notifiers/app_state_notifier.dart';
import '/rest-service/rest_client.dart';
import '/routes/router.dart';
import '/shared-prefs/shared_pref_service.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 239, 255, 1.0),
      body: SafeArea(
        child: Center(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowIndicator();
              return false;
            },
            child: const SingleChildScrollView(
                child: SizedBox(width: 280, child: SignupForm())),
          ),
        ),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return SignupFormState();
  }
}

class SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController acnameEditingController;
  late TextEditingController passwordEditingController;
  late TextEditingController unameTextEditingcontroller;
  late bool _passwordVisible;
  late bool switchValue;
  late final ImagePicker _picker;
  late bool signingUP;
  bool signupSuccess = false;
  XFile? profile_image;

  @override
  void initState() {
    acnameEditingController = TextEditingController();
    passwordEditingController = TextEditingController();
    unameTextEditingcontroller = TextEditingController();
    _passwordVisible = true;
    switchValue = false;
    signingUP = false;
    _picker = ImagePicker();

    super.initState();
  }

  void showPasswordText(bool val) {
    setState(() {
      _passwordVisible = !_passwordVisible;
      switchValue = val;
    });
  }

  void changeSignupState() {
    setState(() {
      signingUP = !signingUP;
    });
  }

  void removeMessenger() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  void signupUser() async {
    if (signupSuccess) return;
    if (_formKey.currentState!.validate()) {
      changeSignupState();
      String? path = (profile_image == null) ? null : profile_image!.path;
      var response = await RestClient.signup(
          acnameEditingController.value.text,
          passwordEditingController.value.text,
          unameTextEditingcontroller.value.text,
          path);
      if (response.containsKey('estatus')) {
        if (mounted) {
          removeMessenger();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['estatus'] as String)));
          changeSignupState();
        }
      } else if (response.containsKey('user_data')) {
        await SharedPrefService.setAuthKey(response['auth-header']);
        if (mounted) {
          Provider.of<AppStateNotifier>(context, listen: false)
              .update(User.newUser(response['user_data']), 1);
          removeMessenger();
          signupSuccess = true;
          changeSignupState();
        }
        await Future.delayed(const Duration(seconds: 1));
        if(mounted){
          Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutePaths.addExtraUserDetails, (route) => false);
        }
      }
    }
  }


  @override
  void dispose() {
    super.dispose();
    acnameEditingController.dispose();
    passwordEditingController.dispose();
    unameTextEditingcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        onWillPop: () async {
          if (signupSuccess) return true;
          if (signingUP) return false;
          return true;
        },
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (mounted) {
                  setState(() {
                    profile_image = image;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.all(20),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  // color: const Color.fromRGBO(128, 250, 250, 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: (profile_image != null)
                          ? Colors.deepPurple
                          : Colors.black,
                      spreadRadius: 5,
                      blurRadius: 0,
                    ),
                    const BoxShadow(
                      color: Color.fromRGBO(223, 217, 248, 1.0),
                      spreadRadius: 2,
                      blurRadius: 0,
                    ),
                  ],
                  border: Border.all(width: 4, color: Colors.black),
                  borderRadius: BorderRadius.circular(150),
                ),
                child: (profile_image == null)
                    ? const Center(
                  child: Icon(Icons.account_circle,size: 35,),
                )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: FadeInImage(
                          key: Key(profile_image!.path),
                          placeholder: const AssetImage('asset/load2.gif'),
                          image: FileImage(File(profile_image!.path)),
                          fit: BoxFit.cover,
                          placeholderFit: BoxFit.scaleDown,
                        ),
                      ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            TextFormField(
              cursorColor: Colors.black,
              maxLength: 15,
              decoration: LSstyles.accountInputDecoration,
              controller: acnameEditingController,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return "Please enter account name!";
                }
                if (!text.contains(RegExp(r"^([A-Za-z]|\d)+$"))) {
                  return "Only alphabets and numbers allowed!";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              cursorColor: Colors.black,
              maxLength: 20,
              decoration: LSstyles.usernameInputDecoration,
              controller: unameTextEditingcontroller,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return "Please enter account name!";
                }
                if (!text.contains(RegExp(r"^([A-Za-z]|\d)+$"))) {
                  return "Only alphabets and numbers allowed!";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              cursorColor: Colors.black,
              maxLength: 18,
              decoration: LSstyles.passwordInputDecoration,
              controller: passwordEditingController,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return "Please enter password!";
                }
                if (text.length < 8) {
                  return "Minimum 8 characters allowed";
                }
                return null;
              },
              obscureText: _passwordVisible,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Switch(
                  value: switchValue,
                  onChanged: showPasswordText,
                  activeColor: Colors.deepPurple,
                ),
                const Text(
                  "show password",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color.fromRGBO(37, 27, 68, 1.0)),
                ),
                const Expanded(child: SizedBox()),
                (signupSuccess)
                    ? TaskPurpleButton(
                        onpressed: () {},
                        buttonWidget: const Text('signed up!'),
                        color: Colors.green)
                    : TaskPurpleButton(
                        onpressed: (!signingUP) ? signupUser : null,
                        buttonWidget: (!signingUP) ? const Text('signup'):const ButtonCircularIndicator(),
                        color: Colors.deepPurple)
              ],
            ),
          ],
        ));
  }
}
