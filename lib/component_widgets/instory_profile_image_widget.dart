import 'package:flutter/material.dart';

class InstoryProfileImage extends StatelessWidget{
  final String accountName;
  const InstoryProfileImage({super.key, required this.accountName});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(
          Radius.circular(45)),
      child: Image.network(
        'http://192.168.29.136:8080/profile-image/$accountName',
        filterQuality: FilterQuality.none,
        height: 55,
        fit: BoxFit.fill,
        width: 55,
        frameBuilder: (_, child, fr, wsl) {
          return SizedBox(
            height: 55,
            width: 55,
            child: ColoredBox(
              color: Colors.deepPurple,
              child: child,
            ),
          );
        },
        loadingBuilder: (_, child, ice) {
          return SizedBox(
            height: 55,
            width: 55,
            child: ColoredBox(
              color: Colors.deepPurple,
              child: child,
            ),
          );
        },
        errorBuilder: (_, r, c) {
          return const SizedBox(
            height: 55,
            width: 55,
            child: Icon(Icons.person,color: Colors.deepPurple,),
          );
        },
      ),
    );
  }
}