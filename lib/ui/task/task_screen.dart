import 'package:flutter/material.dart';
import 'package:flutter_tolist/design_system/styles/spacing_collections.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
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