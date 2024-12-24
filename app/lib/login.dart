// --- Dart/Flutter libraries ---
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  Widget loginActionButton(String text, Function action, String imagePath) {
    return ElevatedButton(
        onPressed: () => action(),
        style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            side: const BorderSide(width: 2)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            imagePath,
            height: 22,
            width: 22,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Text(text),
        ]));
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
        builder: (BuildContext context) => AlertDialog(title: Text(errorTitle), content: Text(errorBody)));
  }

  // Customized AppBar
  PreferredSizeWidget get topBar {
    return AppBar(
        backgroundColor: Colors.deepPurple,
        title: Stack(children: [
          Row(children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double availableWidth = constraints.maxWidth;
                  double fontSize = availableWidth * 0.015;
                  fontSize = fontSize.clamp(16.0, 32.0);

                  return Text(
                    "CatFinderinator3000",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                    ),
                  );
                },
              ),
            ),
            iconTemplate("assets/icon/github_icon.jpeg", "https://github.com/mburnayev"),
            iconTemplate("assets/icon/linkedin_icon.jpeg", "https://www.linkedin.com/in/misha-burnayev/"),
            iconTemplate("assets/icon/about_me_icon.jpeg", "https://mburnayev-website.web.app/"),
          ])
        ]));
  }

  Future<void> anonymousLogin() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Demo()));
    } catch (e) {
      alertTemplate("Demo login error",
          "An unexpected error has occurred:\n${e.toString()}\n\nContact misha@burnayev.com with a screenshot of this error to address this issue.");
    }
  }

  Future<void> googleLogin() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final credentials = FirebaseAuth.instance.currentUser;
      final String? username = credentials?.displayName;

      if (username != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Videos(username: username)));
      }
    } catch (e) {
      alertTemplate("Google login error",
          "An unexpected error has occurred:\n${e.toString()}\n\nContact misha@burnayev.com with a screenshot of this error to address this issue.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topBar,
      body: OverflowBox(
          child: Column(
        children: <Widget>[
          Container(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                child: loginActionButton("Log in with Google", googleLogin, "assets/icon/google_icon.jpeg"),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: loginActionButton("Demo app", anonymousLogin, "assets/icon/incognito_icon.jpeg"),
              ),
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
      )),
    );
  }
}
