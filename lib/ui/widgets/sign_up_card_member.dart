// ignore_for_file: library_private_types_in_public_api

// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urven/ui/screens/code_input_screen.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/email_utils.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/password_utils.dart';
import 'package:urven/utils/text_field.dart';
import 'package:urven/utils/screen_size_configs.dart';

class SignUpCardMember extends StatefulWidget {
  const SignUpCardMember({Key? key}) : super(key: key);

  @override
  _SignUpCardMemberState createState() => _SignUpCardMemberState();
}

class _SignUpCardMemberState extends State<SignUpCardMember> {
    final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedClub;
  DateTime? _selectedBirthday; // New field for selected birthday
  final TextEditingController _birthdayController = TextEditingController(); // Add birthday controller

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
                setState(() {
                  _selectedBirthday = DateFormat('yyyy-MM-dd').parse(value!);
                });
              },
            ),

            const SizedBox(height: SSC.p18),
            RoundedTextField(
              labelText: LU.of(context).choose_club,
              items: [LU.of(context).orchestra, LU.of(context).volunteer],
              onChanged: (value) {
                setState(() {
                  _selectedClub = value;
                });
              },
            ),
            
            const SizedBox(height: SSC.p51),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  if (_nameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                      _passwordController.text.isEmpty ||
                      _selectedClub == null ||
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
                  } else {
                    //success
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CodeInputScreen()),
                    );
                  }
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
                    LU.of(context).next,
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
}
