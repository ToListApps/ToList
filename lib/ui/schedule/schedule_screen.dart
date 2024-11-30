import 'package:flutter/material.dart';
import 'package:flutter_tolist/design_system/styles/spacing_collections.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: SpacingCollections.paddingScreen,
      child: Center(
        child: Image.network('https://i.imgur.com/A7lb8KI.png'),
      ),
    ));
  }
}
