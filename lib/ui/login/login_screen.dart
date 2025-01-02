import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tolistapp/data/provider/user_manager.dart';
import 'package:flutter_tolistapp/ui/navigation/navigation_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
        UserManager().setUser(event);
      });
    });

    _googleSignIn.isSignedIn().then((isSignedin) {
      if (isSignedin) {
        _googleSignIn.disconnect();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/logiinpage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _user != null ? _userInfo() : _googleSignInButton(),
      ),
    );
  }

  Widget _googleSignInButton() {
    return Center(
      child: SizedBox(
        height: 50,
        child: SignInButton(
          Buttons.google,
          text: 'Continue with Google',
          onPressed: _handleGoogleSignIn,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _userInfo() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true, textTheme: GoogleFonts.poppinsTextTheme()),
      home: const BottomNavigationController(),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Token Google tidak valid');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      await _auth.signInWithCredential(credential);
      print('Login berhasil');
    } catch (error) {
      print('Login Google gagal: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login Google gagal: $error')));
    }
  }
}
