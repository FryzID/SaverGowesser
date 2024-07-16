import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.bicycle,
                  color: Colors.black87,
                  size: 100,
                ),
              ],
            ),
            Image.asset(
              'assets/image',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'My App',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
