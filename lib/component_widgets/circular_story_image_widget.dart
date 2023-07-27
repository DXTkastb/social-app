import 'package:flutter/material.dart';

class StoryImageWidget extends StatelessWidget{
  final String accountName;
  const StoryImageWidget({super.key, required this.accountName});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(45)),
      child: Image.network(
        'http://192.168.29.136:8080/profile-image/$accountName',
        filterQuality: FilterQuality.none,
        fit: BoxFit.fill,
        height: 50,
        width: 50,
        frameBuilder: (_, child, fr, wsl) {
          return SizedBox(
            height: 50,
            width: 50,
            child: ColoredBox(
              color: Colors.deepPurple,
              child: child,
            ),
          );
        },
        errorBuilder: (_, r, c) {
          return const SizedBox(
            height: 50,
            width: 50,
            child: Icon(Icons.person,color: Colors.deepPurple,),
          );
        },
      ),
    );
  }
}

class LoadingStoryImageWidget extends StatelessWidget{
  const LoadingStoryImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(45)),
      child: Icon(Icons.person,color: Colors.black,size: 50,)
    );
  }
}