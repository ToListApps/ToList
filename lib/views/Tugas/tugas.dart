import 'package:flutter/material.dart';
import '../../widgets/task_card.dart'; // Reusable TaskCard widget

class TugasScreen extends StatefulWidget {
  @override
  _TugasScreenState createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> {
  bool isPrioritySelected = true; // Tab selection state

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Tugas",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Tab Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kategori Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    isPrioritySelected = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: !isPrioritySelected ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "Kategori",
                    style: TextStyle(
                      color: !isPrioritySelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Priority Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    isPrioritySelected = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: isPrioritySelected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "Priority",
                    style: TextStyle(
                      color: isPrioritySelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Task List
          Expanded(
            child: ListView(
              children: [
                // Tasks for 17th
                TaskDaySection(
                  day: "17",
                  weekday: "Wednesday",
                  tasks: const [
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
                const SizedBox(height: 8),

                // Tasks for 18th
                TaskDaySection(
                  day: "18",
                  weekday: "Thursday",
                  tasks: const [],
                ),
                const SizedBox(height: 8),

                // Tasks for 19th
                TaskDaySection(
                  day: "19",
                  weekday: "Friday",
                  tasks: const [],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for grouping tasks by day
class TaskDaySection extends StatelessWidget {
  final String day;
  final String weekday;
  final List<TaskCard> tasks;

  const TaskDaySection({
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              weekday,
              style: TextStyle(
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
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
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
