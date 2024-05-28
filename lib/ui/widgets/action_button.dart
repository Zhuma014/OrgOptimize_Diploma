// ignore_for_file: depend_on_referenced_packages, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/screen_size_configs.dart';

class ActionButton extends StatelessWidget {
  static const double HEIGHT = SSC.p40;
  static const double CONTENT_PADDING = 10; // Adjust padding as needed

  const ActionButton({
    Key? key,
    this.isEnabled = true,
    this.decoration,
    required this.mainText,
    this.secondaryText,
    this.textStyle,
    required this.onPressed,
  }) : super(key: key);

  final bool isEnabled;
  final Decoration? decoration;
  final String mainText;
  final String? secondaryText;
  final TextStyle? textStyle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      disabledElevation: 1,
      onPressed: isEnabled ? onPressed : null,
      child: Ink(
        decoration: decoration ?? BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(SSC.p4),
          ),
          color: isEnabled ? Palette.MAIN : Colors.grey,
        ),
        child: SizedBox(
          height: HEIGHT,
          child: Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(CONTENT_PADDING),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    mainText,
                    style: textStyle ?? const TextStyle(
                      color: Colors.white,
                      fontSize: SSC.p16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (secondaryText != null) ...[
                    const SizedBox(width: 15),
                    Text(
                      secondaryText!,
                      style: textStyle ?? const TextStyle(
                        color: Colors.white,
                        fontSize: SSC.p16, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
