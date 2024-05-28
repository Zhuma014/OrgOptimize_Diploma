// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urven/app.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/l10n/provider.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/action_button.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/common_dialog.dart';
import 'package:urven/utils/lu.dart';

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
    static const List<Locale> supportedLocales = LU.supportedLocales;

    final formKey = GlobalKey<FormState>();


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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  LU.of(context).select_language,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonHideUnderline(
                  child: DropdownButton<Locale>(
                    icon: const Icon(Icons.keyboard_arrow_down_outlined),
                    iconEnabledColor: Colors.black,
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      color: Palette.DARK_BLUE,
                      fontSize: 16,
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
                         "  ${value.toString()}",
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: ActionButton(
            mainText:"Delete profile",
            onPressed: () {
              _onDeleteAccount();
            },
          ),
        ),
      ],
    ),
  );
}


  void _onDeleteAccount() {
    
      showCustomDialog(
        context: context,
        title: "Delete profile",
        description: "Do you really want to delete your profile",
        positiveText: "Delete",
        negativeText: LU.of(context).action_cancel,
        onPositivePressed: () {
          ooBloc.deleteProfileSubject.listen((event) {
            PreferencesManager.instance.wipeOut();
            Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const OrgOptimizeApp()),
    (route) => false,
  );

          });
          ooBloc.deleteAccount();
        },
      );
    }

  }