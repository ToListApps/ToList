import 'package:flutter/material.dart';
import 'package:flutter_tolistapp/design_system/styles/color_collections.dart';
import 'package:flutter_tolistapp/design_system/styles/typography_collections.dart';

class ButtonCollections {
  static ElevatedButton primary({
    required VoidCallback onPressed,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorCollections.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)
        )
      ),
      child: Text(text, style: TypographyCollections.sh2.copyWith(
        color: ColorCollections.white
      )),
    );
  }
}