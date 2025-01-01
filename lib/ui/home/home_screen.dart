import 'package:flutter/material.dart';
import 'package:flutter_tolistapp/data/provider/user_manager.dart';
import 'package:flutter_tolistapp/design_system/styles/color_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/spacing_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/typography_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/task_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  List<Map<String, dynamic>> _tasks = []; // Menyimpan tugas hari ini

  @override
  void initState() {
    super.initState();
    _fetchTasks(); // Ambil tugas saat widget diinisialisasi
  }

  // Fungsi untuk mengambil tugas dari Supabase
  Future<void> _fetchTasks() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('tolist')
          .select('*')
          .eq('tanggal_akhir', _selectedDay.toIso8601String().substring(0, 10))
          .eq('uid', user!.uid);

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
                          _fetchTasks(); // Ambil tugas setelah tanggal dipilih
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
                  child: _tasks.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada tugas untuk hari ini.',
                            style: TextStyle(fontSize: 16),
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
                              status: task['status'] == true
                                  ? 'Selesai'
                                  : 'Belum Selesai',
                              cardColor: task['prioritas'] == true
                                  ? Colors.red
                                  : Colors.green,
                            );
                          },
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
