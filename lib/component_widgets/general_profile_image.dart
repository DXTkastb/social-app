import 'package:flutter/material.dart';

class GeneralAccountImage extends StatelessWidget{
  final String? fromResource;
  final String accountName;
  final double size;
  const GeneralAccountImage({super.key, required this.accountName, required this.size, this.fromResource});
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: size,
      width: size,
      child: ClipRRect(
          borderRadius:
          BorderRadius
              .circular(50),
          child: Image.network(
           (fromResource!=null)? fromResource!:
              'http://192.168.29.136:8080/profile-image/$accountName',
            fit: BoxFit.fill,
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
                child: const Icon(Icons.person,color: Colors.deepPurple,),
              );
            },
          )),
    );
  }
}