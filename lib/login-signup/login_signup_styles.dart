import 'package:flutter/material.dart';

class LSstyles {
  static final enabledBorder = OutlineInputBorder(
    borderSide: const BorderSide(width: 2.5, color: Color.fromRGBO(
        88, 75, 115, 1.0),),
    borderRadius: BorderRadius.circular(10),
  );

  static final focusedBorder = OutlineInputBorder(
    borderSide: const BorderSide(width: 2.5, color: Colors.deepPurple),
    borderRadius: BorderRadius.circular(10),
  );

  static final errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(width: 2.5, color: Colors.red),
    borderRadius: BorderRadius.circular(10),
  );

  static final ferrorBorder = OutlineInputBorder(
    borderSide: const BorderSide(width: 2.5, color: Color.fromRGBO(
        140, 58, 58, 1.0)),
    borderRadius: BorderRadius.circular(10),
  );

  static const fLS = TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w900,);
  static const lS = TextStyle(color: Color.fromRGBO(88, 75, 115, 1.0),
    fontWeight: FontWeight.w900,
    fontSize: 14
  );
  static final passwordInputDecoration = InputDecoration(
      labelStyle: lS,
      labelText: "Password",
      floatingLabelStyle: fLS,
      errorBorder: errorBorder,
      focusedErrorBorder: ferrorBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder);

  static final accountInputDecoration = InputDecoration(
      labelStyle: lS,
      floatingLabelStyle: fLS,
      labelText: "Account",
      errorBorder: errorBorder,
      focusedErrorBorder: ferrorBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder);

  static final usernameInputDecoration = InputDecoration(
      labelStyle: lS,
      floatingLabelStyle: fLS,
      labelText: "Username",
      errorBorder: errorBorder,
      focusedErrorBorder: ferrorBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder);

  static final delegationInputDecoration = InputDecoration(
      labelStyle: lS,
      floatingLabelStyle: fLS,
      labelText: "Delegation",
      errorBorder: errorBorder,
      focusedErrorBorder: ferrorBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder);

  static final linkInputDecoration = InputDecoration(
      labelStyle: lS,
      floatingLabelStyle: fLS,
      labelText: "Link",
      errorBorder: errorBorder,
      focusedErrorBorder: ferrorBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder);

  static final aboutInputDecoration = InputDecoration(
      labelStyle: lS,
      floatingLabelStyle: fLS,
      labelText: "About",
      errorBorder: errorBorder,
      focusedErrorBorder: ferrorBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder);

}
