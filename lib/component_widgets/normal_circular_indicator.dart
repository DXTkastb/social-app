import 'package:flutter/material.dart';

class NormalCircularIndicator extends StatelessWidget{
  const NormalCircularIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        height: 25,width: 25,
        child: CircularProgressIndicator(color: Colors.deepPurple,strokeWidth: 2,));
  }
}