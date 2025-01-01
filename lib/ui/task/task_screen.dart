import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tolistapp/data/provider/user_manager.dart';
import 'package:flutter_tolistapp/design_system/styles/color_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/spacing_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/typography_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/task_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan hari

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool isPrioritySelected = true;
  List<Map<String, dynamic>> _priorityTasks = [];
  Map<String, List<Map<String, dynamic>>> _categorizedTasks = {};

  @override
  void initState() {
    super.initState();
    _fetchTasks();
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
        .eq('uid', currentUser.uid);

      List<Map<String, dynamic>> tasks =
          List<Map<String, dynamic>>.from(response);

      // Parsing kategori JSON ke List/Map
      for (var task in tasks) {
        if (task['kategori'] is String) {
          task['kategori'] = List<Map<String, dynamic>>.from(
            jsonDecode(task['kategori']),
          );
        }
      }

      // Pisahkan berdasarkan prioritas
      List<Map<String, dynamic>> priorityTasks =
          tasks.where((task) => task['prioritas'] == true).toList();

      // Kelompokkan berdasarkan kategori
      Map<String, List<Map<String, dynamic>>> categorizedTasks = {};
      for (var task in tasks.where((task) => task['prioritas'] == false)) {
        // Pastikan kategori adalah List<Map>
        List<dynamic> kategoriList = task['kategori'] ?? [];
        for (var kategori in kategoriList) {
          // Pastikan kita hanya mengambil nama dari kategori
          String kategoriName = kategori['name'] ?? "Lainnya";
          if (!categorizedTasks.containsKey(kategoriName)) {
            categorizedTasks[kategoriName] = [];
          }
          categorizedTasks[kategoriName]!.add(task);
        }
      }

      setState(() {
        _priorityTasks = priorityTasks;
        _categorizedTasks = categorizedTasks;
      });
        } catch (e) {
      debugPrint('Error fetching tasks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: $e')),
      );
    }
  }

  String _getFormattedDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final String formattedDate =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(parsedDate);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/tugaspage.png', // Path to your background image
              fit: BoxFit.fill,
            ),
          ),
          // Main Content
          Padding(
            padding: SpacingCollections.paddingScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Text(
                    "Tugas",
                    style: TypographyCollections.h1.copyWith(
                      color: ColorCollections.primary,
                    ),
                  ),
                ),
                const SizedBox(height: SpacingCollections.xl),

                // Toggle Switch
                Center(
                  child: ToggleSwitch(
                    minWidth: 150,
                    cornerRadius: 20.0,
                    activeBgColors: [
                      [ColorCollections.lightBlue],
                      [ColorCollections.lightBlue]
                    ],
                    activeFgColor: Colors.white,
                    inactiveBgColor: ColorCollections.primary,
                    inactiveFgColor: Colors.white,
                    initialLabelIndex: isPrioritySelected ? 1 : 0,
                    totalSwitches: 2,
                    labels: ['Kategori', 'Prioritas'],
                    radiusStyle: true,
                    onToggle: (index) {
                      setState(() {
                        isPrioritySelected = index == 1;
                      });
                    },
                  ),
                ),
                const SizedBox(height: SpacingCollections.xl),

                // Task List
                Expanded(
                  child: isPrioritySelected
                      ? _priorityTasks.isEmpty
                          ? const Center(
                              child: Text(
                                "Tidak ada tugas prioritas.",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _priorityTasks.length,
                              itemBuilder: (context, index) {
                                final task = _priorityTasks[index];
                                return TaskCard(
                                  startTime:
                                      task['waktu_mulai']?.toString() ?? '',
                                  endTime:
                                      task['waktu_akhir']?.toString() ?? '',
                                  title: task['nama'] ?? '',
                                  subtitle: task['deskripsi'] ?? '',
                                  status: task['prioritas'] == true
                                      ? 'Prioritas Tinggi'
                                      : 'Biasa',
                                  cardColor: Colors.red,
                                );
                              },
                            )
                      : _categorizedTasks.isEmpty
                          ? const Center(
                              child: Text(
                                "Tidak ada tugas untuk kategori ini.",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            )
                          : ListView(
                              children: _categorizedTasks.entries.map((entry) {
                                final kategoriName = entry.key; // kategoriName sebagai String
                                final tasks = entry.value;

                                return TaskDaySection(
                                  day: "",
                                  weekday: kategoriName, // kategoriName langsung digunakan
                                  tasks: tasks.map((task) {
                                    return TaskCard(
                                      startTime:
                                          task['waktu_mulai']?.toString() ?? '',
                                      endTime:
                                          task['waktu_akhir']?.toString() ?? '',
                                      title: task['nama'] ?? '',
                                      subtitle: task['deskripsi'] ?? '',
                                      status: task['prioritas'] == true
                                          ? 'Prioritas Tinggi'
                                          : 'Biasa',
                                      cardColor: Colors.green,
                                    );
                                  }).toList(),
                                );
                              }).toList(),
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

class TaskDaySection extends StatelessWidget {
  final String day;
  final String weekday;
  final List<TaskCard> tasks;

  const TaskDaySection({
    super.key,
    required this.day,
    required this.weekday,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Row(
          children: [
            Text(
              day,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              weekday,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const Divider(thickness: 1),

        // Tasks or empty state
        tasks.isNotEmpty
            ? Column(children: tasks)
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Tidak ada tugas",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
      ],
    );
  }
}
