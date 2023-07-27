import 'package:flutter/material.dart';
import '/routes/router.dart';

class BottomAddSheetContainer extends StatelessWidget {
  const BottomAddSheetContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 30,),
            Expanded(
                child: Center(
                  child:
                  Material(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    color: const Color.fromRGBO(207, 179, 255, 1.0),
                    child: InkWell(
                      focusColor: Colors.deepPurpleAccent,
                      highlightColor: Colors.deepPurple,
                      splashColor: const Color.fromRGBO(148, 100, 236, 1.0),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutePaths.uploadView,arguments: 2);
                      },
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.image_sharp,
                                size: 35,
                              ),
                              Text(
                                'Post',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                )),
            Expanded(
                child: Center(
                  child:
                  Material(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    color: const Color.fromRGBO(207, 179, 255, 1.0),
                    child: InkWell(
                      focusColor: Colors.deepPurpleAccent,
                      highlightColor: Colors.deepPurple,
                      splashColor: const Color.fromRGBO(148, 100, 236, 1.0),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutePaths.uploadView,arguments: 1);
                      },
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.ac_unit_sharp,
                                size: 35,
                              ),
                              Text(
                                'Story',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                )),
            const SizedBox(width: 30,),
          ],
        ),
      ),
    );
  }
}
