import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:socio/component_widgets/bottom_buttons.dart';
import 'package:socio/login-signup/login_signup_styles.dart';

import '../data/user_details.dart';
import '/change_notifiers/app_state_notifier.dart';
import '/rest-service/rest_client.dart';
import '/routes/router.dart';
import '/shared-prefs/shared_pref_service.dart';
import '../component_widgets/button_circular_indicator.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

// const Color.fromRGBO(244, 239, 255, 1.0),

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 239, 255, 1.0),
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color.fromRGBO(244, 239, 255, 1.0),
        ),
        leading: null,
        toolbarOpacity: 0,
        bottomOpacity: 0,
        title: null,
        toolbarHeight: 0,
        leadingWidth: 0,
        actions: null,
        flexibleSpace: null,
        elevation: 0,
        shadowColor: null,
      ),
      body: const Center(
          child: SingleChildScrollView(
              child: SizedBox(width: 250, child: LoginForm()))),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  late FocusNode focusNode1 = FocusNode();
  late FocusNode focusNode2 = FocusNode();
  late TextEditingController acnameEditingController;
  late TextEditingController passwordEditingController;
  late bool loginIn;
  late bool logInSuccessful;
  late bool _passwordVisible;
  late bool switchValue;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    acnameEditingController = TextEditingController();
    passwordEditingController = TextEditingController();
    loginIn = false;
    logInSuccessful = false;
    _passwordVisible = true;
    switchValue = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    acnameEditingController.dispose();
    passwordEditingController.dispose();
  }

  void showPasswordText(bool val) {
    setState(() {
      _passwordVisible = !_passwordVisible;
      switchValue = val;
    });
  }

  void changeLoginState(bool loginSuccess) {
    setState(() {
      loginIn = !loginIn;
      logInSuccessful = loginSuccess;
    });
  }

  void showSnackBar(String title) {
    final snackBar = SnackBar(content: Text(title));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void removeMessenger() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  Future<void> login() async {
    focusNode1.unfocus();
    focusNode2.unfocus();
    if (_formKey.currentState!.validate()) {
      removeMessenger();
      changeLoginState(false);

      Map response = await RestClient.login(acnameEditingController.value.text,
          passwordEditingController.value.text);

      if (response.containsKey('estatus')) {
        if (mounted) {
          removeMessenger();
          showSnackBar(response['estatus'] as String);
          acnameEditingController.clear();
          passwordEditingController.clear();
          changeLoginState(false);
        }
      } else if (response.containsKey('user_data')) {
        await SharedPrefService.setAuthKey(response['auth-header']);
        if (mounted) {
          changeLoginState(true);
          var appStateProvider  =
          Provider.of<AppStateNotifier>(context, listen: false);
              appStateProvider.update(User.newUser(response['user_data']), 1);
              appStateProvider.updateAppUser();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              cursorColor: Colors.black,
              focusNode: focusNode1,
              maxLength: 15,
              decoration: LSstyles.accountInputDecoration,
              controller: acnameEditingController,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return "Please enter account name!";
                }
                if (!text.contains(RegExp(r"^([A-Za-z]|\d)+$"))) {
                  return "Invalid account name!";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              cursorColor: Colors.black,
              focusNode: focusNode2,
              maxLength: 18,
              decoration: LSstyles.passwordInputDecoration,
              controller: passwordEditingController,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return "Please enter password!";
                }
                return null;
              },
              obscureText: _passwordVisible,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (!loginIn)
                    ? TaskPurpleButton(
                        onpressed: login,
                        buttonWidget: (logInSuccessful)
                            ? const Text('logged in!')
                            : const Text('submit'),
                        color: (logInSuccessful)
                            ? Colors.green
                            : Colors.deepPurple)
                    : const TaskPurpleButton(
                        onpressed: null,
                        buttonWidget: ButtonCircularIndicator(),
                        color: Colors.deepPurple),
                const VerticalDivider(
                  width: 15,
                ),
                TaskPurpleButton(
                    onpressed: (!loginIn)
                        ? () {
                            Navigator.of(context).pushNamed('signup');
                          }
                        : () {},
                    buttonWidget: const Text('sign up'),
                    color: Colors.black)
              ],
            )
          ],
        ));
  }
}
