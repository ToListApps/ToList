import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/task_card.dart'; // Import widget reusable TaskCard

class JadwalScreen extends StatefulWidget {
  @override
  _JadwalScreenState createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_focusedDay.day} ${_getMonthName(_focusedDay.month)} ${_focusedDay.year}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                      selectedDecoration: BoxDecoration(
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
            const SizedBox(height: 10),

            // Task List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tambahkan fungsi untuk action di sini
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Fungsi untuk mendapatkan nama bulan
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
}
