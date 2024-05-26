// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/internal/bloc/cubits/bottom_nav_bar_bloc.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/email_utils.dart';
import 'package:urven/utils/logger.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/password_utils.dart';
import 'package:urven/ui/widgets/text_field.dart';
import 'package:urven/utils/screen_size_configs.dart';
import 'package:urven/wrapper.dart';

class SignUpCard extends StatefulWidget {
  const SignUpCard({Key? key}) : super(key: key);

  @override
  _SignUpCardState createState() => _SignUpCardState();
}

class _SignUpCardState extends State<SignUpCard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController =
      TextEditingController(); // Add birthday controller

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _birthdayController.dispose(); // Dispose birthday controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: SSC.p20),
            RoundedTextField(
              labelText: LU.of(context).full_name,
              controller: _nameController,
            ),
            const SizedBox(height: SSC.p18),
            RoundedTextField(
              labelText: LU.of(context).email,
              controller: _emailController,
            ),
            const SizedBox(height: SSC.p18),
            RoundedTextField(
              labelText: LU.of(context).password,
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: SSC.p18),
            RoundedTextField(
              labelText: LU.of(context).birthday,
              isBirthdayField: true,
              controller: _birthdayController, // Use birthday controller
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: SSC.p51),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _performSignUp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.MAIN,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Text(
                    LU.of(context).registration,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SSC.p20),
          ],
        ),
      ),
    );
  }

  void _performSignUp() {
    String fullName = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String birthday = _birthdayController.text;
    String? fcm_token = PreferencesManager.instance.getFirebaseMessagingToken();

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _birthdayController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LU.of(context).please_fill_all_fields),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (!_emailController.text.isEmail()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LU.of(context).enter_correct_email),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (!_passwordController.text.isValidPassword()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LU.of(context).enter_valid_password),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    ooBloc.signUp(email, password, DateTime.parse(birthday), fullName, fcm_token: fcm_token!);
    ooBloc.signUpSubject.stream.listen((value) {
      Logger.d(
          'SignUpCard', 'ooBloc.signUpStream.listen() -> ${value.isValid}');

      if (value.isValid) {
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _birthdayController.clear();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainWrapper()),
          (route) => route.isFirst,
        );
        context.read<BottomNavBarCubit>().changeSelectedIndex(0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign Up Failed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
