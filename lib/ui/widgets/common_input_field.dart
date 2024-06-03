// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter/services.dart';

import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/primitive/string_utils.dart';
import 'package:urven/utils/screen_size_configs.dart';

class CommonInputField extends StatelessWidget {
  const CommonInputField({super.key, 
    this.margin = const EdgeInsets.only(
      left: SSC.p15,
      top: SSC.p5,
      right: SSC.p15,
    ),
    this.labelText,
    this.isRequired = false,
    required this.controller,
    this.initialValue,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.readOnly = false,
    this.minLines = 1,
    this.inputFormatters,
    this.validator,
    this.onTap,

  });

  final EdgeInsets margin;
  final bool isRequired;
  final String? labelText;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction; 
  final bool readOnly;
  final int minLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String? value)? validator;
  final VoidCallback? onTap; 


  List<Widget> buildHeaderWidget() {
    String? labelText = this.labelText;
    if (labelText == null || labelText.isNullOrBlank()) {
      return [
        const SizedBox(height: SSC.p10),
      ];
    } else {
      List<TextSpan> children = [];

      if (isRequired) {
        children.add(
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
              fontSize: SSC.p14,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }

      return [
        RichText(
          text: TextSpan(
            text: labelText,
            style: TextStyle(
              color: Palette.MAIN.withOpacity(0.5),
              fontSize: SSC.p14,
              fontWeight: FontWeight.w400,
            ),
            children: children,
          ),
        ),
        const SizedBox(height: SSC.p6),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...buildHeaderWidget(),
          TextFormField(
            autocorrect: false,
            controller: initialValue == null ? controller : null,
            initialValue: initialValue,
            keyboardType: keyboardType,
            readOnly: readOnly,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            minLines: minLines,
            maxLines: 5,
            inputFormatters: inputFormatters,
            enableInteractiveSelection: !readOnly,
            textAlign: TextAlign.left,
            validator: validator,
            onTap: onTap, 
            style: TextStyle(
              color: readOnly ? Palette.DARK_GREY_3 : Palette.DARK_BLUE,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: EdgeInsets.only(
                left: SSC.p10,
                top: minLines > 1 ? SSC.p10 : 0,
                bottom: minLines > 1 ? SSC.p10 : 0,
              ),
              hintStyle: TextStyle(
                color: Palette.DARK_GREY_2.withOpacity(0.7),
                fontSize: SSC.p15,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: readOnly ? Palette.SOLITUDE : Colors.white70,
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(SSC.p4),
                ),
                borderSide: BorderSide(color: Palette.LIGHT_GREY_4),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(SSC.p4),
                ),
                borderSide: BorderSide(color: Palette.LIGHT_GREY_4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
