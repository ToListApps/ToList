import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateStatusScreen extends StatelessWidget {
  final int taskId;
  final bool currentStatus; // Current status of the task (completed or not)

  const UpdateStatusScreen({
    super.key,
    required this.taskId,
    required this.currentStatus,
  });

  // Function to update the task status
  Future<void> _updateTaskStatus(
      BuildContext context, int taskId, bool currentStatus) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('tolist')
          .update({'status': !currentStatus})
          .eq('id', taskId)
          .select();

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status berhasil diperbarui')),
        );
        Navigator.pop(context); // Kembali ke layar sebelumnya setelah update
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perbarui Status Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Apakah Anda yakin ingin mengubah status tugas ini?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () =>
                      _updateTaskStatus(context, taskId, currentStatus),
                  child: Text(currentStatus
                      ? 'Tandai Belum Selesai'
                      : 'Tandai Selesai'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
