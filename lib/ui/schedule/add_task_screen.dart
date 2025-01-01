import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tolistapp/data/provider/user_manager.dart';
import 'package:flutter_tolistapp/design_system/styles/color_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/spacing_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/typography_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/button_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/dialog_collections.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  bool isPriority = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;

  final List<Map<String, dynamic>> _selectedCategories = [];
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCategories = prefs.getString('categories');
    if (savedCategories != null) {
      setState(() {
        _selectedCategories.addAll(
          List<Map<String, dynamic>>.from(json.decode(savedCategories)),
        );
      });
    }
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = json.encode(_selectedCategories);
    await prefs.setString('categories', categoriesJson);
  }

  Future<void> _addCategory() async {
    await DialogCollections.showAddCategoryDialog(
      context: context,
      onAddCategory: (String categoryName, Color categoryColor) {
        setState(() {
          _selectedCategories.add({
            'name': categoryName,
            'color': categoryColor.value,
          });
        });
        _saveCategories();
      },
    );
  }

  void _removeCategory(String name) {
    setState(() {
      _selectedCategories.removeWhere((category) => category['name'] == name);
    });
    _saveCategories();
  }

  Widget _buildCategoryChip(String name, int colorValue) {
    return Chip(
      label: Text(name),
      backgroundColor: Color(colorValue),
      labelStyle: TypographyCollections.p1.copyWith(color: Colors.white),
      onDeleted: () => _removeCategory(name),
    );
  }

  Future<void> _pickStartDate() async {
    DateTime? pickedDate = await showOmniDateTimePicker(
      context: context,
      type: OmniDateTimePickerType.date,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedStartDate = pickedDate;
        selectedEndDate = pickedDate.add(const Duration(days: 1));
        selectedStartTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          9,
        );
        selectedEndTime = selectedStartTime!.add(const Duration(hours: 1));
      });
    }
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    DateTime? pickedTime = await showOmniDateTimePicker(
      context: context,
      type: OmniDateTimePickerType.time,
      initialDate: DateTime.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          selectedStartTime = DateTime(
            selectedStartDate?.year ?? DateTime.now().year,
            selectedStartDate?.month ?? DateTime.now().month,
            selectedStartDate?.day ?? DateTime.now().day,
            pickedTime.hour,
            pickedTime.minute,
          );
          selectedEndTime = selectedStartTime!.add(const Duration(hours: 1));
        } else {
          selectedEndTime = DateTime(
            selectedEndDate?.year ?? DateTime.now().year,
            selectedEndDate?.month ?? DateTime.now().month,
            selectedEndDate?.day ?? DateTime.now().day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    DateTime? pickedDate = await showOmniDateTimePicker(
      context: context,
      type: OmniDateTimePickerType.date,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: selectedStartDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedEndDate = pickedDate;
        if (selectedEndTime != null) {
          selectedEndTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            selectedEndTime!.hour,
            selectedEndTime!.minute,
          );
        }
      });
    }
  }

  Future<void> _addTaskToSupabase({
    required String nama,
    required String deskripsi,
    required DateTime tanggal_awal,
    required String waktuMulai,
    required String waktuAkhir,
    required List<Map<String, dynamic>> kategori,
    required bool prioritas,
    required DateTime tanggalAkhir,
  }) async {
    final supabase = Supabase.instance.client;
    final currentUser = UserManager().getUser();

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User tidak ditemukan.')),
      );
      return;
    }

    final uid = currentUser.uid;

    try {
      final response = await supabase.from('tolist').insert({
        'nama': nama,
        'deskripsi': deskripsi,
        'tanggal_awal': tanggal_awal.toIso8601String(),
        'waktu_mulai': waktuMulai,
        'waktu_akhir': waktuAkhir,
        'kategori': kategori,
        'prioritas': prioritas,
        'tanggal_akhir': tanggalAkhir.toIso8601String(),
        'uid': uid, // Tambahkan UID ke Supabase
      }).select();

      if (response.isEmpty) {
        throw Exception('Respons dari server kosong atau null');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil ditambahkan!')),
      );

      Navigator.pop(context);
      _clearFields();
    } catch (e) {
      debugPrint('Error saat menambahkan tugas: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _clearFields() {
    _namaController.clear();
    _deskripsiController.clear();
    selectedStartDate = null;
    selectedEndDate = null;
    selectedStartTime = null;
    selectedEndTime = null;
    _selectedCategories.clear();
    isPriority = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Tugas'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Menambahkan tombol kembali
          },
        ),
      ),
      body: Padding(
        padding: SpacingCollections.paddingScreen,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Tambah Tugas',
                    style: TypographyCollections.h1.copyWith(
                      color: ColorCollections.primary,
                    ),
                  ),
                ),
                SizedBox(height: SpacingCollections.xl),
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    hintText: 'Nama Tugas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: SpacingCollections.xl),
                TextField(
                  controller: _deskripsiController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Deskripsi...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: SpacingCollections.xl),
                GestureDetector(
                  onTap: _pickStartDate,
                  child: TextField(
                    enabled: false,
                    controller: TextEditingController(
                      text: selectedStartDate != null
                          ? '${selectedStartDate!.day}-${selectedStartDate!.month}-${selectedStartDate!.year}'
                          : 'Pilih Tanggal Mulai',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tanggal Mulai',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: SpacingCollections.l),
                GestureDetector(
                  onTap: _pickEndDate,
                  child: TextField(
                    enabled: false,
                    controller: TextEditingController(
                      text: selectedEndDate != null
                          ? '${selectedEndDate!.day}-${selectedEndDate!.month}-${selectedEndDate!.year}'
                          : 'Pilih Tanggal Selesai',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tanggal Selesai',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: SpacingCollections.xl),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickTime(isStartTime: true),
                        child: TextField(
                          enabled: false,
                          controller: TextEditingController(
                            text: selectedStartTime != null
                                ? '${selectedStartTime!.hour}:${selectedStartTime!.minute}'
                                : 'Waktu Mulai',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Waktu Mulai',
                            suffixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SpacingCollections.xl),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickTime(isStartTime: false),
                        child: TextField(
                          enabled: false,
                          controller: TextEditingController(
                            text: selectedEndTime != null
                                ? '${selectedEndTime!.hour}:${selectedEndTime!.minute}'
                                : 'Waktu Selesai',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Waktu Selesai',
                            suffixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SpacingCollections.xl),
                Text(
                  'Pilih Kategori',
                  style: TypographyCollections.p1,
                ),
                SizedBox(height: SpacingCollections.xl),
                Wrap(
                  spacing: SpacingCollections.l,
                  children: [
                    ..._selectedCategories.map((category) {
                      return _buildCategoryChip(
                          category['name'], category['color']);
                    }).toList(),
                    GestureDetector(
                      onTap: _addCategory,
                      child: CircleAvatar(
                        backgroundColor: ColorCollections.primary,
                        child: Icon(Icons.add, color: ColorCollections.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SpacingCollections.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jadikan Prioritas',
                      style: TypographyCollections.p1,
                    ),
                    Switch(
                      value: isPriority,
                      onChanged: (value) {
                        setState(() {
                          isPriority = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: SpacingCollections.xl),
                Center(
                  child: SizedBox(
                    width: 255,
                    child: ButtonCollections.primary(
                      onPressed: () {
                        if (_namaController.text.isEmpty ||
                            selectedStartDate == null ||
                            selectedStartTime == null ||
                            selectedEndDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Mohon lengkapi semua data')),
                          );
                          return;
                        }

                        final nama = _namaController.text;
                        final deskripsi = _deskripsiController.text;
                        final tanggal_awal = selectedStartDate!;
                        final tanggalAkhir = selectedEndDate!;
                        final waktuMulai =
                            '${selectedStartTime!.hour}:${selectedStartTime!.minute}';
                        final waktuAkhir =
                            '${selectedEndTime!.hour}:${selectedEndTime!.minute}';
                        final prioritas = isPriority;

                        _addTaskToSupabase(
                          nama: nama,
                          deskripsi: deskripsi,
                          tanggal_awal: tanggal_awal,
                          waktuMulai: waktuMulai,
                          waktuAkhir: waktuAkhir,
                          kategori: _selectedCategories,
                          prioritas: prioritas,
                          tanggalAkhir: tanggalAkhir,
                        );
                      },
                      text: 'Tambah Tugas',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
