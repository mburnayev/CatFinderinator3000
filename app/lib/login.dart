import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cat_finderinator_threethousand/home.dart';

// Login entrypoint
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controllers used to intake user credentials
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

  // retrieves email field text
  Widget get emailField {
    return TextField(controller: emailCtrl,
        decoration: const InputDecoration(labelText: "Email"));
  }

  // retrieves password field text
  Widget get pwdField {
    return TextFormField(controller: pwdCtrl,
        decoration: const InputDecoration(labelText: "Password"),
        obscureText: true);
  }

  Widget get loginButton {
    return ElevatedButton(onPressed: login, child: const Text("Log in"));
  }

  // Alert popup in the event a user with invalid credentials tries to log in
  Widget get bagLoginAlert {
    return const AlertDialog(title: Text("Login error"),
        content: Text("Invalid username and/or password"));
  }

  // gives or denies access depending on user's presence in Firebase Auth db
  Future<void> login() async {
    try {
      // determines whether user credentials are in Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailCtrl.text, password: pwdCtrl.text);
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
      }
    } catch (e) {
      showDialog(context: context, builder: (BuildContext context) => bagLoginAlert);
    }
  }

}