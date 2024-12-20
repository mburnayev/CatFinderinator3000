// --- Dart/Flutter libraries ---
import 'package:flutter/material.dart';

// --- Miscellaneous Libraries
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_sign_in/google_sign_in.dart';

// --- Local Package Files ---
import 'package:cat_finderinator_threethousand/videos.dart';
import 'package:cat_finderinator_threethousand/demo.dart';

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
          color: Colors.white,
        ),
        onPressed: () async {
          if (await canLaunchUrlString(url)) {
            await launchUrlString(url);
          }
        });
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
      child: ConstrainedBox(
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
              Expanded(
                child: const Text(
                  "CatFinderinator3000",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              iconTemplate("assets/icon/github_icon.jpeg",
                  "https://github.com/mburnayev"),
              iconTemplate("assets/icon/linkedin_icon.jpeg",
                  "https://www.linkedin.com/in/misha-burnayev/"),
              iconTemplate("assets/icon/about_me_icon.jpeg",
                  "https://mburnayev-website.web.app/"),
              Container(width: 20)
            ],
          )
        ],
      ),
      centerTitle: false,
      backgroundColor: Colors.deepPurple,
      elevation: 4,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
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

  Future<void> anonymousLogin() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Demo()));
    } catch (e) {
      alertTemplate("Demo login error",
          "An unexpected error has occurred, contact misha@burnayev.com");
    }
  }

  Future<void> googleLogin() async {
    try {
      // Trigger auth flow, get auth details from the request
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final credentials =
          await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Videos()));
    } catch (e) {
      alertTemplate("Google login error",
          "An unexpected error has occurred:\n${e.toString()}\n\nContact misha@burnayev.com for resolution");
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
          Container(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              loginActionButton("Log in with Google", googleLogin),
              loginActionButton("Demo app anonymously", anonymousLogin),
            ],
          ),
          Container(height: 20),
          Row(
            children: <Widget>[
              imageTemplate("assets/fullres/login_cat_left.jpeg", true),
              imageTemplate("assets/fullres/login_cat_center.jpeg", true),
              imageTemplate("assets/fullres/login_cat_right.jpeg", true)
            ],
          ),
          imageTemplate("assets/fullres/login_cat_filler.jpeg", false)
        ],
      ))),
    );
  }
}
