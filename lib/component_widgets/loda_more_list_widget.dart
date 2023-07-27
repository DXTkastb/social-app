import 'package:flutter/material.dart';

class LoadMoreWidgetList extends StatelessWidget{
  const LoadMoreWidgetList({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(
          height: 35,width: 35,
          child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ),
        SizedBox(
          width: 7,
        ),
        Text(
          '...',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}