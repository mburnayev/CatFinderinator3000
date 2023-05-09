import 'package:cat_finderinator_threethousand/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", pwd = "";
  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();

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
    return TextFormField(validator: (input) {
      if (input!.isEmpty) {
        return "email@xyz.com";
      }
    },
        onSaved: (input) => email = input!,
        decoration: const InputDecoration(labelText: "Email")
    );
  }

  Widget get pwdField {
    return TextFormField(validator: (input) {
      if (input!.isEmpty) {
        return "password";
      }
    },
        onSaved: (input) => pwd = input!,
        decoration: const InputDecoration(labelText: "Password"),
        obscureText: true
    );
  }

  Widget get loginButton {
    return ElevatedButton(onPressed: login, child: const Text("Log in"));
  }
  
  Future<void> login() async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pwd);
        if (context.mounted){
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
        }
      } catch (e) {
        print("Login failed!");
      }
  }
}