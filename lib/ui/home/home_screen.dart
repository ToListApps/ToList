import 'package:flutter/material.dart';
import 'package:flutter_tolistapp/data/provider/user_manager.dart';
import 'package:flutter_tolistapp/design_system/styles/color_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/spacing_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/typography_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/task_card.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = UserManager().getUser();
  bool _isCalendarExpanded = true; // Mengatur status kalender
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

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
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/homepage.png',
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: SpacingCollections.paddingScreen,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${getGreetings()}, \n${user!.displayName ?? ''}',
                      style: TypographyCollections.sh1.copyWith(
                        color: ColorCollections.primary,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(user!.photoURL!),
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isCalendarExpanded ? 350 : 80,
                    child: SingleChildScrollView(
                      physics: _isCalendarExpanded
                          ? const NeverScrollableScrollPhysics()
                          : const AlwaysScrollableScrollPhysics(),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarStyle: CalendarStyle(
                          selectedDecoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.blue[100],
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isCalendarExpanded = !_isCalendarExpanded;
                    });
                  },
                  icon: Icon(
                    _isCalendarExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
                const SizedBox(height: 20),
                // Task List Header
                const Text(
                  "Today's Tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Task List
                Expanded(
                  child: ListView(
                    children: const [
                      TaskCard(
                        startTime: "10.00",
                        endTime: "13.00",
                        title: "Design New UX flow for .....",
                        subtitle: "Start from screen 16",
                        status: "1 Assignment Successfully",
                        cardColor: Colors.green,
                      ),
                      TaskCard(
                        startTime: "14.00",
                        endTime: "15.00",
                        title: "Brainstorm with the team",
                        subtitle: "Define the problem or ...",
                        status: "1 Assignment Missing",
                        cardColor: Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
