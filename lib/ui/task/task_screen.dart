import 'package:flutter/material.dart';
import 'package:flutter_tolistapp/design_system/styles/color_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/spacing_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/typography_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/task_card.dart';
import 'package:toggle_switch/toggle_switch.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool isPrioritySelected = true;
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

                Center(
                  child: ToggleSwitch(
                    minWidth: 150,
                    cornerRadius: 20.0,
                    activeBgColors: [[ColorCollections.lightBlue], [ColorCollections.lightBlue]],
                    activeFgColor: Colors.white,
                    inactiveBgColor: ColorCollections.primary,
                    inactiveFgColor: Colors.white,
                    initialLabelIndex: 1,
                    totalSwitches: 2,
                    labels: ['Kategori', 'Prioritas'],
                    radiusStyle: true,
                    onToggle: (index) {
                      print('switched to: $index');
                    },
                  ),
                ),
                const SizedBox(height: SpacingCollections.xl),
                // Task List
                Expanded(
                  child: ListView(
                    children: const [
                      // Tasks for 17th
                      TaskDaySection(
                        day: "17",
                        weekday: "Wednesday",
                        tasks: [
                          TaskCard(
                            startTime: "10.00",
                            endTime: "13.00",
                            title: "Design New UX flow for .....",
                            subtitle: "Prioritas | Start from screen 16",
                            status: "",
                            cardColor: Colors.green,
                          ),
                          TaskCard(
                            startTime: "14.00",
                            endTime: "15.00",
                            title: "Brainstorm with the team",
                            subtitle: "Prioritas | Define the problem or ..",
                            status: "",
                            cardColor: Colors.purple,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      // Tasks for 18th
                      TaskDaySection(
                        day: "18",
                        weekday: "Thursday",
                        tasks: [],
                      ),
                      SizedBox(height: 8),

                      // Tasks for 19th
                      TaskDaySection(
                        day: "19",
                        weekday: "Friday",
                        tasks: [],
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
