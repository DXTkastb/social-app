import 'package:flutter/material.dart';

class GeneralImageWidget extends StatelessWidget{
  final String imageUrl;
  final IconData errorIcon;
  final double size;
  const GeneralImageWidget({super.key, required this.imageUrl, required this.size, required this.errorIcon});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      height: size,
      width: size,
      frameBuilder: (_, child, fr, wsl) {
        return SizedBox(
          height: size,
          width: size,
          child: ColoredBox(
            color: Colors.deepPurple,
            child: child,
          ),
        );
      },
      loadingBuilder: (_, child, ice) {
        return SizedBox(
          height: size,
          width: size,
          child: ColoredBox(
            color: Colors.deepPurple,
            child: child,
          ),
        );
      },
      errorBuilder: (_, r, c) {
        return SizedBox(
          height: size,
          width: size,
          child: Icon(errorIcon,color: Colors.redAccent,),
        );
      },
    );
  }
}