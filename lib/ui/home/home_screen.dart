import 'package:flutter/material.dart';
import 'package:flutter_tolist/data/provider/user_manager.dart';
import 'package:flutter_tolist/design_system/styles/color_collections.dart';
import 'package:flutter_tolist/design_system/styles/spacing_collections.dart';
import 'package:flutter_tolist/design_system/styles/typography_collections.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = UserManager().getUser();

  String getGreetings() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Selamat Pagi";
    } else if (hour >= 12 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: SpacingCollections.paddingScreen,
        child: Center(
          child: Column(
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${getGreetings()}, \n${user!.displayName ?? ''}', 
                      style: TypographyCollections.sh1.copyWith(
                        color: ColorCollections.primary
                      )),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: NetworkImage(user!.photoURL!)),
                        borderRadius: BorderRadius.circular(25)
                      ),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}