import 'package:flutter/material.dart';
import 'package:myapp/View/LoginPage.dart';
import 'package:myapp/View/RegisterPage.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: toggleScreens);
    } else {
      return RegisterPage(
        onTap: toggleScreens,
        );
    }
  }
}