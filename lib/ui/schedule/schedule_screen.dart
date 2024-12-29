import 'package:flutter/material.dart';
import 'package:flutter_tolistapp/design_system/styles/color_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/spacing_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/task_card.dart';
import 'package:flutter_tolistapp/ui/schedule/add_task_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/jadwalpage.png'), // Path to your PNG file
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: SpacingCollections.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SpacingCollections.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${_focusedDay.day} ${_getMonthName(_focusedDay.month)} ${_focusedDay.year}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: SpacingCollections.l),
                    TableCalendar(
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
                      calendarFormat:
                          CalendarFormat.week, // Tampilkan hanya satu baris
                      availableCalendarFormats: const {
                        CalendarFormat.week:
                            'Week', // Nonaktifkan opsi format lain
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerVisible: false,
                      daysOfWeekVisible: true,
                    ),
                  ],
                ),
              ),

              // Task List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SpacingCollections.xl),
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddTaskScreen()));
        },
        backgroundColor: ColorCollections.primary,
        child: const Icon(Icons.add, color: ColorCollections.white),
      ),
    );
  }
}

String _getMonthName(int month) {
  const monthNames = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember"
  ];
  return monthNames[month - 1];
}
