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
  // Controller used to intake user credentials
  var emailCtrl = TextEditingController(), pwdCtrl = TextEditingController();

  // Generalized widget for adding icons
  Widget iconTemplate(String iconPath, String url) {
    return IconButton(
        icon: ImageIcon(
          AssetImage(iconPath),
          size: 24,
          color: Colors.white,
        ),
        onPressed: () async {
          if (await canLaunchUrlString(url)) {
            await launchUrlString(url);
          }
        });
  }

  // Generalized widget for the input fields
  Widget inputField(String label, TextEditingController ctrl, bool obscure) {
    return SizedBox(
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

  // Generalized widget for the buttons
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

  // Generalized widget for rendering images
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

  // Generalized call to display a dialogue
  void alertTemplate(String errorTitle, String errorBody) {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(title: Text(errorTitle), content: Text(errorBody)));
  }

  // Customized AppBar
  PreferredSizeWidget get topBar {
    return AppBar(
      actions: [],
      title: Stack(
        children: [
          Row(
            children: [
              iconTemplate(
                  "icon/github_icon.jpeg", "https://github.com/mburnayev"),
              iconTemplate("icon/linkedin_icon.jpeg",
                  "https://www.linkedin.com/in/misha-burnayev/"),
              iconTemplate("icon/about_me_icon.jpeg", "https://www.google.com")
            ],
          ),
          Center(
            child: const Text(
              "CatFinderinator3000 Login Page",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
      backgroundColor: Colors.deepPurple,
      elevation: 4,
    );
  }

  // Adds user to the db if they don't exist, otherwise display appropriate dialogue
  Future<void> register() async {
    String emailText = emailCtrl.text;
    String pwdText = pwdCtrl.text;
    if (emailText.isNotEmpty && pwdText.isNotEmpty) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailText, password: pwdText);
        alertTemplate("Account successfully created!", "");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          alertTemplate(
              "Account creation error", "The password provided is too weak!");
        } else if (e.code == 'email-already-in-use') {
          alertTemplate("Account creation error",
              "The account already exists for that email!");
        }
      } catch (e) {
        alertTemplate(
            "Account creation error", "Something went unexpectedly wrong!");
      }
    } else {
      alertTemplate("Account creation error",
          "You need to enter valid credentials to create a new account!");
    }
  }

  // Gives or denies access depending on user's presence in Firebase Auth db
  Future<void> login() async {
    if (context.mounted) {
      try {
        // determines whether user credentials are in Firebase Auth
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailCtrl.text, password: pwdCtrl.text);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Videos()));
        emailCtrl.clear();
        pwdCtrl.clear();
      } catch (e) {
        alertTemplate("Login error", "Invalid username and/or password!");
      }
    }
  }

  // Sends an email with a link to reset your password given a username/email
  Future<void> forgotPassword() async {
    String emailText = emailCtrl.text;
    if (emailText.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: emailText);
      } catch (err) {
        alertTemplate(
            "Password reset error", "Password reset email failed to send!");
      }
    } else {
      alertTemplate("Password reset error",
          "Please enter an associated email to reset a password for!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topBar,
      body: Form(
          child: OverflowBox(
              child: Column(
                children: <Widget>[
                  inputField("Email (Username)", emailCtrl, false),
                  inputField("Password", pwdCtrl, true),
                  Container(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      loginActionButton("Forgot Password?", forgotPassword),
                      loginActionButton("Sign Up", register),
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
}
