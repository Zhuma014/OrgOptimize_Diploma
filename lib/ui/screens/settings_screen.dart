// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urven/l10n/provider.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';

class SettingsScreen extends StatelessWidget {
  static const List<Locale> supportedLocales = LU.supportedLocales;

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Toolbar(
              isBackButtonVisible: true,
              title: LU.of(context).settings,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(
                SSC.p15,
                0,
                SSC.p15,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    LU.of(context).select_language,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Locale>(
                        icon: const Icon(Icons.keyboard_arrow_down_outlined,
                            size: SSC.p18),
                        iconEnabledColor: Colors.black,
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Palette.DARK_BLUE,
                          fontSize: SSC.p14,
                          fontWeight: FontWeight.w400,
                        ),
                        underline: Container(
                          height: 1,
                          color: Palette.DARK_BLUE,
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          provider.setLocale(value);
                        },
                        value: provider.locale ?? LU.defaultLocale,
                        items: supportedLocales.map((value) {
                          return DropdownMenuItem<Locale>(
                            value: value,
                            child: Text(
                              value.toString(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
