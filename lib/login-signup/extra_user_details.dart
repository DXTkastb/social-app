import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:socio/component_widgets/bottom_buttons.dart';
import 'package:socio/component_widgets/button_circular_indicator.dart';
import 'package:socio/rest-service/rest_client.dart';

import '../change_notifiers/app_state_notifier.dart';
import 'login_signup_styles.dart';

class ExtraUserDetailsPage extends StatelessWidget {
  const ExtraUserDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromRGBO(207, 190, 255, 1.0),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 280,
            child: ExtraUserDetailsForm(),
          ),
        ),
      ),
    );
  }
}

class ExtraUserDetailsForm extends StatefulWidget {
  const ExtraUserDetailsForm({super.key});

  @override
  State<ExtraUserDetailsForm> createState() => _ExtraUserDetailsFormState();
}

class _ExtraUserDetailsFormState extends State<ExtraUserDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController delegationController;
  late TextEditingController aboutController;
  late TextEditingController linkController;
  bool extraDetailsSubmitted = false;
  bool uploadingExtraDetails = false;

  @override
  void initState() {
    super.initState();
    delegationController = TextEditingController();
    aboutController = TextEditingController();
    linkController = TextEditingController();
  }

  void changeUploadingState() {
    setState(() {
      uploadingExtraDetails = !uploadingExtraDetails;
    });
  }

  void removeMessenger() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  void uploadExtraUserDetailsData() async {

    String x1 = delegationController.value.text;
    String x2 = linkController.value.text;
    String x3 = aboutController.value.text;

    if (x1.isEmpty && x2.isEmpty && x3.isEmpty) return;

    if (extraDetailsSubmitted) return;

    if (!(_formKey.currentState!.validate())) return;

    changeUploadingState();

    var provider = Provider.of<AppStateNotifier>(context, listen: false);
    String accountName = provider.user.accountname;
    String uname = provider.user.username;
    var response =
        await RestClient.addExtraUserDetails(accountName, x1, x2, x3,uname);
    if (response.containsKey('estatus')) {
      if (mounted) {
        removeMessenger();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['estatus'] as String)));
        changeUploadingState();
      }
    } else if (response.containsKey('user_data')) {
      if (mounted) {
        extraDetailsSubmitted = true;
        changeUploadingState();

      }
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        provider
            .updateDataOnStarup(response['user_data']);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    var appStateProvider = Provider.of<AppStateNotifier>(context, listen: false);
    return Form(
        onWillPop: () async {
          return false;
        },
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.text,
              cursorColor: Colors.black,
              maxLength: 50,
              minLines: 1,
              maxLines: 2,
              decoration: LSstyles.delegationInputDecoration,
              controller: delegationController,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return null;
                }
                var words = text.split(r" ");
                for(var x in words) {
                  if (!(x.contains(
                      RegExp(r"[a-zA-Z\d]+")))) {
                    return "Only alphabets and numbers allowed!";
                  }
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField( keyboardType: TextInputType.text,
              cursorColor: Colors.black,
              minLines: 1,
              maxLines: 2,
              maxLength: 50,
              decoration: LSstyles.linkInputDecoration,
              controller: linkController,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return null;
                }
                var words = text.split(r" ");
                for(var x in words) {
                  if (!x.contains(
                      RegExp(r"^(www.)[a-zA-Z\d]+((.com)|(.in)|(.netlify.app))$"))) {
                    return "Only alphabets and numbers allowed! (www.example.com)";
                  }
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              keyboardType: TextInputType.text,
              cursorColor: Colors.black,
              minLines: 1,
              maxLines: 3,
              maxLength: 100,
              decoration: LSstyles.aboutInputDecoration,
              controller: aboutController,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return null;
                }
                var words = text.split(r" ");
                for(var x in words) {
                  if (!x.contains(
                      RegExp(r"[a-zA-Z\d]+"))) {
                    return "Only alphabets and numbers allowed!";
                  }
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TaskPurpleButton(
                    onpressed: (uploadingExtraDetails)
                        ? null
                        : () {
                            if (extraDetailsSubmitted) return;
                            appStateProvider.updateAppUser();
                          },
                    buttonWidget: const Text('skip'),
                    color: Colors.deepPurpleAccent),
                (extraDetailsSubmitted)
                    ? TaskPurpleButton(
                        onpressed: () {},
                        buttonWidget: const Text('submitted'),
                        color: Colors.green)
                    : TaskPurpleButton(
                        onpressed: uploadExtraUserDetailsData,
                        buttonWidget: (uploadingExtraDetails)
                            ? const ButtonCircularIndicator()
                            : const Text('submit'),
                        color: Colors.deepPurple),
              ],
            )
          ],
        ));
  }
}
