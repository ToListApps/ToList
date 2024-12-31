import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyController extends GetxController {
  // Data dengan observable
  var data = <Map<String, dynamic>>[].obs;

  // Map untuk menghitung jumlah per hari
  Map<String, int> countDateMap = {
    'Minggu': 0,
    'Senin': 0,
    'Selasa': 0,
    'Rabu': 0,
    'Kamis': 0,
    'Jumat': 0,
    'Sabtu': 0,
  };

  // Mendapatkan nama hari dari tanggal
  String getDayName(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return days[date.weekday - 1];
  }

  Future<void> fetchTasks() async {
    final supabase = Supabase.instance.client;

    // Hitung awal minggu (Senin) dan akhir minggu (Minggu) berdasarkan hari ini
    final today = DateTime.now();
    final startDate =
        today.subtract(Duration(days: today.weekday - 1)); // Hari Senin
    final endDate = startDate.add(Duration(days: 6)); // Hari Minggu

    try {
      final response = await supabase
          .from('tolist')
          .select('*')
          .gte('tanggal_akhir', startDate.toIso8601String().substring(0, 10))
          .lte('tanggal_akhir', endDate.toIso8601String().substring(0, 10));

      // Update data jika fetch berhasil
      data.value = List<Map<String, dynamic>>.from(response);
      calculateCountDate();
      print(data); // Untuk keperluan debug
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      Get.snackbar(
        'Error',
        'Error fetching tasks: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fungsi untuk menghitung jumlah per hari
  Future<void> calculateCountDate() async {
    // Reset countDateMap sebelum penghitungan ulang
    countDateMap.updateAll((key, value) => 0);

    for (var item in data) {
      // Pastikan data memiliki kunci 'tanggal_akhir' sebelum parsing
      if (item.containsKey('tanggal_akhir')) {
        DateTime date = DateTime.parse(item['tanggal_akhir']);
        String dayName = getDayName(date);

        // Periksa apakah hari tersedia di countDateMap
        if (countDateMap.containsKey(dayName)) {
          countDateMap[dayName] = countDateMap[dayName]! + 1;
        }
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }
}
