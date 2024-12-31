import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductivityChart extends StatefulWidget {
  const ProductivityChart({super.key});

  @override
  State<ProductivityChart> createState() => _ProductivityChartState();
}

class _ProductivityChartState extends State<ProductivityChart> {
  // Observable data dan count map
  final data = <Map<String, dynamic>>[].obs;
  final countDateMap = <String, int>{
    'Minggu': 0,
    'Senin': 0,
    'Selasa': 0,
    'Rabu': 0,
    'Kamis': 0,
    'Jumat': 0,
    'Sabtu': 0,
  }.obs;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

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

  // Ambil data dari Supabase
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

      // Hitung jumlah per hari
      calculateCountDate();
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
  void calculateCountDate() {
    countDateMap.updateAll((key, value) => 0); // Reset count map

    for (var item in data) {
      if (item.containsKey('tanggal_akhir')) {
        DateTime date = DateTime.parse(item['tanggal_akhir']);
        String dayName = getDayName(date);

        if (countDateMap.containsKey(dayName)) {
          countDateMap[dayName] = countDateMap[dayName]! + 1;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Map nama hari ke indeks untuk digunakan di sumbu X
      final dayNames = [
        'Minggu',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu'
      ];
      final barGroups = List.generate(dayNames.length, (index) {
        final dayName = dayNames[index];
        final count =
            countDateMap[dayName] ?? 0; // Default 0 jika tidak ada data
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.blueAccent,
              width: 16,
            ),
          ],
        );
      });

      // Hitung nilai maksimum fleksibel berdasarkan data
      final maxY = countDateMap.values.isNotEmpty
          ? (countDateMap.values.reduce((a, b) => a > b ? a : b) + 1).toDouble()
          : 1.0;

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY, // Atur batas maksimum fleksibel
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // Set interval untuk sumbu kiri
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles:
                  SideTitles(showTitles: false), // Hilangkan label kanan
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false), // Hilangkan label atas
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dayNames.length) {
                    return Text(dayNames[index],
                        style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          gridData: const FlGridData(show: false),
          barGroups: barGroups, // Gunakan barGroups yang sudah kita buat
        ),
      );
    });
  }
}
