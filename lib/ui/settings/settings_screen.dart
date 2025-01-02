import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tolistapp/data/provider/user_manager.dart';
import 'package:flutter_tolistapp/design_system/styles/color_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/spacing_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/typography_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/button_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/chart.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final user = UserManager().getUser();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/settingpage.png'), // Path to your PNG file
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: SpacingCollections.paddingScreen,
          child: Center(
            child: Column(
              children: [
                Text(
                  'Pengaturan',
                  style: TypographyCollections.h1.copyWith(
                    color: ColorCollections.primary
                  ),
                ),
                const SizedBox(
                  height: SpacingCollections.xxl,
                ),
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage(user!.photoURL!)),
                    borderRadius: BorderRadius.circular(30)
                  ),
                ),
                const SizedBox(height: SpacingCollections.xl),
                Text(
                  '${user!.displayName}',
                  style: TypographyCollections.sh2.copyWith(
                    color: ColorCollections.primary
                  )
                ),
                const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Produktivitas:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: SpacingCollections.xl),
              Expanded(
                child: ProductivityChart(),
              ),
                const SizedBox(height: SpacingCollections.xl),
                SizedBox(
                  width: 255,
                  child: ButtonCollections.primary(
                    onPressed: () async {
                      await _logout();
                    }, 
                    text: 'Logout'
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      // Gunakan instance GoogleSignIn yang konsisten
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Periksa jika pengguna sudah login dan disconnect jika perlu
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }

      // Logout dari Firebase
      await _auth.signOut();

      // Hapus data pengguna dari UserManager
      UserManager().setUser(null);

      // Berikan feedback keberhasilan logout
      print('Logout berhasil');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout berhasil')),
      );

      // Opsional: Navigasi ke layar login jika diperlukan
      // Navigator.pushReplacementNamed(context, '/login');
    } catch (error) {
      print('Logout Gagal: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Gagal: $error')),
      );
    }
  }
}