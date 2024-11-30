import 'package:flutter/material.dart';
import 'package:flutter_tolist/design_system/styles/color_collections.dart';
import 'package:flutter_tolist/ui/home/home_screen.dart';
import 'package:flutter_tolist/ui/schedule/schedule_screen.dart';
import 'package:flutter_tolist/ui/settings/settings_screen.dart';
import 'package:flutter_tolist/ui/task/task_screen.dart';

class BottomNavigationController extends StatefulWidget {
  const BottomNavigationController({super.key});

  @override
  State<BottomNavigationController> createState() => BottomNavigationControllerState();
}

class BottomNavigationControllerState extends State<BottomNavigationController> {
  int _currentIndex = 0;
  static List<Widget> _page = <Widget> [
    HomeScreen(),
    ScheduleScreen(),
    TaskScreen(),
    SettingsScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available),
            label: 'Jadwal'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tugas'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan' 
          )
        ],
        currentIndex: _currentIndex,
        selectedItemColor: ColorCollections.primary,
        unselectedItemColor: ColorCollections.secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}