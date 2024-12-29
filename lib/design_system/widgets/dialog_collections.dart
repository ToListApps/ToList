import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_tolistapp/design_system/styles/color_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/spacing_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/typography_collections.dart';

class DialogCollections {
  static Future<void> showAddCategoryDialog({
    required BuildContext context,
    required Function(String categoryName, Color categoryColor) onAddCategory,
  }) async {
    final TextEditingController categoryController = TextEditingController();
    Color? selectedColor;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Tambah Kategori',
                      style: TypographyCollections.h2.copyWith(
                        color: ColorCollections.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: SpacingCollections.l),
                  TextField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      hintText: 'Nama Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: ColorCollections.secondary,
                    ),
                  ),
                  SizedBox(height: SpacingCollections.l),
                  Text(
                    'Pilih Warna Kategori',
                    style: TypographyCollections.p1.copyWith(
                      color: ColorCollections.primary,
                    ),
                  ),
                  SizedBox(height: SpacingCollections.m),
                  Wrap(
                    spacing: SpacingCollections.s,
                    runSpacing: SpacingCollections.s,
                    children: [
                      ...[Colors.black, Colors.blue, Colors.yellow, Colors.green, Colors.purple, Colors.pink, Colors.red, Colors.orange, Colors.cyan]
                          .map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 20,
                            child: selectedColor == color
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }),
                      GestureDetector(
                        onTap: () async {
                          final Color? color = await showColorPickerDialog(
                            context: context,
                            initialColor: selectedColor ?? Colors.black,
                          );
                          if (color != null) {
                            setState(() {
                              selectedColor = color;
                            });
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          radius: 20,
                          child: Icon(Icons.color_lens, color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SpacingCollections.l),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.cancel, color: ColorCollections.secondary),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: ColorCollections.primary),
                        onPressed: () {
                          if (categoryController.text.isNotEmpty &&
                              selectedColor != null) {
                            onAddCategory(categoryController.text, selectedColor!);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static Future<Color?> showColorPickerDialog({
    required BuildContext context,
    required Color initialColor,
  }) async {
    Color tempColor = initialColor;

    return await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Warna'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (Color color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Pilih'),
              onPressed: () {
                Navigator.of(context).pop(tempColor);
              },
            ),
          ],
        );
      },
    );
  }
}
