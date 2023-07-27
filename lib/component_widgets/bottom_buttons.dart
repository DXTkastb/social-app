import 'package:flutter/material.dart';

class TaskPurpleButton extends StatelessWidget {
  final void Function()? onpressed;
  final Widget buttonWidget;
  final Color color;

  const TaskPurpleButton({super.key,required this.onpressed, required this.buttonWidget, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onpressed,
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(color),
            shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ))),
        child: buttonWidget);
  }
}

class TaskPurpleButtonWithIcon extends StatelessWidget {
  final void Function()? onpressed;
  final Widget buttonWidget;
  final Color color;
  final IconData iconData;

  const TaskPurpleButtonWithIcon({super.key,required this.onpressed, required this.buttonWidget, required this.color, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: onpressed,
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(color),
            shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ))),
        icon: Icon(iconData),
        label: buttonWidget);
  }
}

class CancelButton extends StatelessWidget{
  final void Function() onpressed;

  const CancelButton({super.key, required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onpressed,
        style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.black),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ))),
        child: const Text('cancel'));
  }


}


class OkButton extends StatelessWidget{
  final void Function() onpressed;

  const OkButton({super.key, required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onpressed,
        style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.black),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ))),
        child: const Text('ok'));
  }


}