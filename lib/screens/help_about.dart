import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(244, 239, 255, 1.0),
        body: LayoutBuilder(builder: (ctx, boxConstraints) {
          return Center(
            child: Container(
              height: boxConstraints.maxWidth,
              width: boxConstraints.maxWidth,
            decoration: BoxDecoration(
             // color: Colors.green,
              borderRadius: BorderRadius.circular(boxConstraints.maxWidth/2)
            ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children:   [
                  Image(image: const AssetImage('asset/app_icon.png'),
                    height: boxConstraints.maxWidth/2.5,
                      color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 20,),
                  const Text('SOCIAL',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900,),textAlign: TextAlign.center,),
                  const SizedBox(height: 5,),
                  const Text('social media app for sharing images',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)

                ],
              ),
            ),
            
          );
        },)
    );
  }
}


