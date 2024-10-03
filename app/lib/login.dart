// --- Dart/Flutter libraries ---
import 'package:flutter/material.dart';

// --- Miscellaneous Libraries
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher_string.dart';

// --- Local Package Files ---
import 'package:cat_finderinator_threethousand/videos.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // controller used to intake user credentials
  var emailCtrl = TextEditingController(), pwdCtrl = TextEditingController();

  PreferredSizeWidget get topBar {
    return AppBar(
      title: const Text(
        "CatFinderinator3000 Login Page",
        style: TextStyle(
          fontSize: 24, // Increased font size\
          color: Colors.white, // Text color
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.deepPurple,
      elevation: 4,
      actions: [
        IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () async {
              const url = 'https://github.com/mburnayev';
              if (await canLaunchUrlString(url)) {
                await launchUrlString(url);
              } else {
                throw 'Could not launch $url';
              }
            }),
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
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(text)),
    );
  }

  // generalized widget for the images
  Widget imageTemplate(String imgPath, bool isFixed) {
    Widget fixed = Expanded(
      child: Image.asset(
        imgPath,
        fit: BoxFit.fill,
      ),
    );

    Widget flexible = Expanded(
      child: Container(
        constraints: BoxConstraints.expand(),
        child: Image.asset(
          imgPath,
          fit: BoxFit.fill,
        ),
      ),
    );

    return isFixed ? fixed : flexible;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topBar,
      body: Form(
          child: OverflowBox(
              // maxWidth: MediaQuery.of(context).size.hright + 1,
              child: Column(
        children: <Widget>[
          inputField("Email (Username)", emailCtrl, false),
          inputField("Password", pwdCtrl, true),
          Container(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              loginActionButton("Forgot Password?", forgotPassword),
              loginActionButton("Sign Up", login),
              loginActionButton("Log in", login),
            ],
          ),
          Container(height: 20),
          Row(
            children: <Widget>[
              imageTemplate("fullres/login_cat_left.jpeg", true),
              imageTemplate("fullres/login_cat_center.jpeg", true),
              imageTemplate("fullres/login_cat_right.jpeg", true)
            ],
          ),
          imageTemplate("fullres/login_cat_filler.jpeg", false)
        ],
      ))),
    );
  }

  // Alert popup in the event a user with invalid credentials tries to log in
  Widget get bagLoginAlert {
    return const AlertDialog(
        title: Text("Login error"),
        content: Text("Invalid username and/or password"));
  }

  void onFailure() {
    showDialog(
        context: context, builder: (BuildContext context) => bagLoginAlert);
  }

  // gives or denies access depending on user's presence in Firebase Auth db
  Future<void> login() async {
    try {
      // determines whether user credentials are in Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text, password: pwdCtrl.text);
      if (context.mounted) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Videos()));
        emailCtrl.clear();
        pwdCtrl.clear();
      }
    } catch (e) {
      onFailure();
    }
  }

  Future<void> forgotPassword() async {
    String emailText = emailCtrl.text;
    if (emailText.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: emailText);
      } catch (err) {
        print(err.toString());
      }
    } else {
      print("new dialogue here");
    }
  }
}
