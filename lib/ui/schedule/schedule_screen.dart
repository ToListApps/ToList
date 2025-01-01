import 'package:flutter/material.dart';
import 'package:flutter_tolistapp/data/provider/user_manager.dart';
import 'package:flutter_tolistapp/design_system/styles/color_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/spacing_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/task_card.dart';
import 'package:flutter_tolistapp/ui/schedule/add_task_screen.dart';
import 'package:flutter_tolistapp/ui/schedule/edit_task_screen.dart';
import 'package:flutter_tolistapp/ui/schedule/delete_task_screen.dart';
import 'package:flutter_tolistapp/ui/schedule/update_status_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks(); // Fetch tasks on initial load
  }

  Future<void> _fetchTasks() async {
    final supabase = Supabase.instance.client;
    
    final currentUser = UserManager().getUser();

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User tidak ditemukan.')),
      );
      return;
    }

    try {
      final response = await supabase
          .from('tolist')
          .select('*')
          .eq('tanggal_akhir', _selectedDay.toIso8601String().substring(0, 10))
          .eq('uid', currentUser.uid);

      if (mounted) {
        setState(() {
          _tasks = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching tasks: $e')),
        );
      }
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _fetchTasks(); // Fetch tasks for the selected day
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/jadwalpage.png'),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingCollections.xl),
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
                      onDaySelected: _onDaySelected,
                      calendarFormat: CalendarFormat.week,
                      availableCalendarFormats: const {
                        CalendarFormat.week: 'Week',
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: SpacingCollections.xl),
                  child: _tasks.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada tugas untuk tanggal ini.',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            return TaskCard(
                              startTime: task['waktu_mulai'] ?? '',
                              endTime: task['waktu_akhir'] ?? '',
                              title: task['nama'] ?? '',
                              subtitle: task['deskripsi'] ?? '',
                              status: (task['status'] ?? false)
                                  ? 'Selesai'
                                  : 'Belum Selesai',
                              cardColor: (task['prioritas'] ?? false)
                                  ? Colors.red
                                  : Colors.green,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon:
                                        Icon(Icons.check, color: Colors.green),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => UpdateStatusScreen(
                                            taskId: task['id'],
                                            currentStatus:
                                                task['status'] ?? false,
                                          ),
                                        ),
                                      ).then((_) => _fetchTasks());
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EditTaskScreen(task: task),
                                        ),
                                      ).then((_) => _fetchTasks());
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DeleteTaskScreen(
                                            taskId: task['id'],
                                          ),
                                        ),
                                      ).then((_) => _fetchTasks());
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
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
            context,
            MaterialPageRoute(builder: (_) => AddTaskScreen()),
          ).then((_) => _fetchTasks());
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
