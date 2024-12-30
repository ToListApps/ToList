import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tolistapp/design_system/styles/color_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/spacing_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/typography_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/button_collections.dart';
import 'package:flutter_tolistapp/design_system/widgets/dialog_collections.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
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
    _loadTaskData();
  }

  void _loadTaskData() {
    _namaController.text = widget.task['nama'] ?? '';
    _deskripsiController.text = widget.task['deskripsi'] ?? '';
    isPriority = widget.task['prioritas'] ?? false;
    selectedStartDate = DateTime.tryParse(widget.task['tanggal_awal'] ?? '');
    selectedEndDate = DateTime.tryParse(widget.task['tanggal_akhir'] ?? '');
    selectedStartTime = selectedStartDate;
    selectedEndTime = selectedEndDate;
    _selectedCategories
        .addAll(List<Map<String, dynamic>>.from(widget.task['kategori'] ?? []));
  }

  Future<void> _pickDate(bool isStart) async {
    DateTime? pickedDate = await showOmniDateTimePicker(
      context: context,
      type: OmniDateTimePickerType.date,
      initialDate: isStart
          ? selectedStartDate ?? DateTime.now()
          : selectedEndDate ?? DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          selectedStartDate = pickedDate;
        } else {
          selectedEndDate = pickedDate;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStartTime) async {
    DateTime? pickedTime = await showOmniDateTimePicker(
      context: context,
      type: OmniDateTimePickerType.time,
      initialDate: DateTime.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          selectedStartTime = pickedTime;
        } else {
          selectedEndTime = pickedTime;
        }
      });
    }
  }

  Future<void> _updateTask() async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('tolist').update({
        'nama': _namaController.text,
        'deskripsi': _deskripsiController.text,
        'tanggal_awal': selectedStartDate?.toIso8601String(),
        'tanggal_akhir': selectedEndDate?.toIso8601String(),
        'waktu_mulai':
            '${selectedStartTime?.hour}:${selectedStartTime?.minute}',
        'waktu_akhir': '${selectedEndTime?.hour}:${selectedEndTime?.minute}',
        'kategori': _selectedCategories,
        'prioritas': isPriority,
      }).eq('id', widget.task['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui tugas: $e')),
      );
    }
  }

  void _addCategory() async {
    await DialogCollections.showAddCategoryDialog(
      context: context,
      onAddCategory: (String categoryName, Color categoryColor) {
        setState(() {
          _selectedCategories.add({
            'name': categoryName,
            'color': categoryColor.value,
          });
        });
      },
    );
  }

  void _removeCategory(String name) {
    setState(() {
      _selectedCategories.removeWhere((category) => category['name'] == name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tugas'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
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
                    'Edit Tugas',
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
                  onTap: () => _pickDate(true),
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
                  onTap: () => _pickDate(false),
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
                        onTap: () => _pickTime(true),
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
                        onTap: () => _pickTime(false),
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
                SizedBox(
                  width: double.infinity,
                  child: ButtonCollections.primary(
                    onPressed: _updateTask,
                    text: 'Simpan Perubahan',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String name, int color) {
    return Chip(
      label: Text(name),
      backgroundColor: Color(color),
      onDeleted: () => _removeCategory(name),
    );
  }
}
