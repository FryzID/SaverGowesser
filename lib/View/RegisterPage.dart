import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/Components/Input_Button.dart';
import 'package:myapp/Components/Input_comp.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ConfirmPasswordController = TextEditingController();

  void signUserUp() async {

      showDialog(context: context, builder: (context) {
        return const Center(child: CircularProgressIndicator(),
        );
      },
      );
      try{
        if(passwordController.text == ConfirmPasswordController.text) {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
        } else {
          showErrorMessage('Password Tidak Sesuai');
        }
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
              const SizedBox(height: 10),
          
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
                'Ayo Daftarkan Emailmu',
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

              //Password
              const SizedBox(height: 10),
              InputComp(
                controller: ConfirmPasswordController,
                hintText: 'Konfirmasi Password',
                obscureText: true,
              ),
          
              const SizedBox(height: 30),
              InputButton(
                text: "Daftar",
                onTap: signUserUp,
              ),
          
              const SizedBox(height: 10),
              Row(
          // Suggested code may be subject to a license. Learn more: ~LicenseLog:4241664267.
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah Memiliki Akun?'),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      '   Login',
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