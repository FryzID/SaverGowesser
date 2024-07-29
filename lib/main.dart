import 'package:flutter/material.dart';
import 'package:myapp/View/AuthPage.dart';
import 'package:myapp/View/HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/View/LoginPage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}