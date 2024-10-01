import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cat_finderinator_threethousand/videos.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // controller used to intake user credentials
  final emailCtrl = TextEditingController(), pwdCtrl = TextEditingController();

  PreferredSizeWidget get topBar {
    return AppBar(
      title: const Text(
        "CatFinderinator3000 Login Page",
        style: TextStyle(
          fontSize: 24, // Increased font size
          color: Colors.white, // Text color
        ),
      ),
      centerTitle: true, // Center the title
      backgroundColor: Colors.deepPurple, // Background color
      elevation: 4, // Shadow effect
      actions: [
        IconButton(
          icon: const Icon(Icons.stop),
          tooltip: 'Debug',
          onPressed: () async {
            const url = 'https://github.com/mburnayev';
            if (await canLaunchUrlString(url)) {
              await launchUrlString(url);
            } else {
              throw 'Could not launch $url';
            }
          }
        ),
      ],
    );
  }

  // generalized widget for the input fields
  Widget inputField(String label, TextEditingController ctrl, bool obscure) {
    return SizedBox(
        // width: 500,
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(0),
                  child: TextField(
                    controller: ctrl,
                    obscureText: obscure,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(), labelText: label),
                  ))
            ])));
  }

  // generalized widget for the buttons
  Widget loginActionButton(String text, Function action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
        onPressed: () => action(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(text)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topBar,
        body: Form(
            child: Column(
              children: <Widget>[
                inputField("Email (Username)", emailCtrl, false),
                inputField("Password", pwdCtrl, true),
                Container(height: 20),
                Row(children: <Widget>[
                  loginActionButton("Forgot Password?", forgotPassword),
                  loginActionButton("Sign Up", login),
                  loginActionButton("Log in", login)
                ])
              ],
            )));
  }

  // Alert popup in the event a user with invalid credentials tries to log in
  Widget get bagLoginAlert {
    return const AlertDialog(
        title: Text("Login error"),
        content: Text("Invalid username and/or password"));
  }

  // gives or denies access depending on user's presence in Firebase Auth db
  Future login() async {
    try {
      // determines whether user credentials are in Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text, password: pwdCtrl.text);
      if (context.mounted) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Videos()));
      }
    } catch (e) {
      showDialog(context: context, builder: (context) => bagLoginAlert);
    }
  }

  Future forgotPassword() async {
    String emailText = emailCtrl.text;
    if (emailText.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: emailText);
      } catch (err) {
        print(err.toString());
      }
    }
    else {
      print("new dialogue here");
    }
  }
}
