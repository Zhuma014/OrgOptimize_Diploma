// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/screen_size_configs.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key, 
    required this.text,
    this.edgeInsets = EdgeInsets.zero,
  });

  final String text;
  final EdgeInsets edgeInsets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: edgeInsets,
      child: Text(
        text,
        style: const TextStyle(
          color: Palette.DARK_BLUE,
          letterSpacing: 0,
          height: 1.15,
          fontSize: SSC.p18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}