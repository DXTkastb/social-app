import 'package:flutter/material.dart';

class ButtonCircularIndicator extends StatelessWidget{
  const ButtonCircularIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        width: 15,
        height: 15,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 1,
        ));
  }
}