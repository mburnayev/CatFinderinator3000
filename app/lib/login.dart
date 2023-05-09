import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cat_finderinator_threethousand/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailCtrl = TextEditingController(), pwdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("CatFinderinator3000 login page")
      ),
      body: Form(
        child: Column(
          children: <Widget>[
            emailField,
            pwdField,
            Container(height: 20),
            loginButton
          ],
        )
      )
    );
  }

  Widget get emailField {
    return TextField(controller: emailCtrl,
        decoration: const InputDecoration(labelText: "Email"));
  }

  Widget get pwdField {
    return TextFormField(controller: pwdCtrl,
        decoration: const InputDecoration(labelText: "Password"),
        obscureText: true);
  }

  Widget get loginButton {
    return ElevatedButton(onPressed: login, child: const Text("Log in"));
  }

  Widget get bagLoginAlert {
    return const AlertDialog(title: Text("Login error"), content: Text("Invalid username and/or password"));
  }
  
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailCtrl.text, password: pwdCtrl.text);
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
      }
    } catch (e) {
      showDialog(context: context, builder: (BuildContext context) => bagLoginAlert);
    }
  }
}