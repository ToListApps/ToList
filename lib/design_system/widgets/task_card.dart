import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String startTime; // Waktu mulai
  final String endTime; // Waktu selesai
  final String title; // Judul tugas
  final String subtitle; // Deskripsi singkat tugas
  final String status; // Status tugas
  final Color cardColor; // Warna indikator tugas
  final Widget? trailing; // Widget tambahan untuk aksi (Edit/Delete)

  const TaskCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.cardColor,
    this.trailing, // Trailing opsional
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indikator Warna
            Container(
              width: 8,
              height: 60,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),

            // Informasi Tugas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Waktu
                  Text(
                    "$startTime - $endTime",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Judul Tugas
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subjudul
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Status
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing (Edit & Delete Button atau Opsi Lain)
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(
                    left: 8.0), // Add some space between task info and trailing
                child: trailing,
              )
            else
              const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
