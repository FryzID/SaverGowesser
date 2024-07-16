import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/Components/Input_Button.dart';
import 'package:myapp/Components/Input_comp.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {

      showDialog(context: context, builder: (context) {
        return const Center(child: CircularProgressIndicator(),
        );
      },
      );
      try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        showErrorMessage(e.code);
      }

      Navigator.pop(context);
    }

    void showErrorMessage(String message) {
      showDialog(context: context,
      builder: (builder) {
        return AlertDialog(
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        );      
      },
    );
  }

  

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
          
              const SizedBox(height: 10),
              const SizedBox(height: 50),
          
              //Logo
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
          
              const SizedBox(height: 50),
              const Text(
                'Selamat Datang',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
                  
              
          
          
              //Username
              const SizedBox(height: 40),
              InputComp(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
          
              //Password
              const SizedBox(height: 10),
              InputComp(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
          
              const SizedBox(height: 40),
              InputButton(
                text: "Login",
                onTap: signUserIn,
              ),
          
              const SizedBox(height: 10),
              Row(
          // Suggested code may be subject to a license. Learn more: ~LicenseLog:4241664267.
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum Memiliki Akun?'),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      '   Daftar',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
            ),
        ),
        ),
      ),
    );
    
  }
}