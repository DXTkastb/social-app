import 'dart:async';

import 'package:flutter/material.dart';

import '../routes/router.dart';

class MaterialAppX extends StatelessWidget {
  final int routeNumber;

  const MaterialAppX({super.key, required this.routeNumber});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutePaths.getInitialRoute(routeNumber),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
