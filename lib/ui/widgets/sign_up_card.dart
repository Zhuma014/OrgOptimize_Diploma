// ignore_for_file: library_private_types_in_public_api

// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/ui/screens/code_input_screen.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/email_utils.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/password_utils.dart';
import 'package:urven/utils/text_field.dart';
import 'package:urven/utils/screen_size_configs.dart';

class SignUpCard extends StatefulWidget {
  const SignUpCard({super.key});

  @override
  _SignUpCardState createState() => _SignUpCardState();
}

class _SignUpCardState extends State<SignUpCard> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedStatus;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
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
              labelText: LU.of(context).phone_number,
              controller: _phoneNumberController,
            ),
            const SizedBox(height: SSC.p18),
            RoundedTextField(
              labelText: LU.of(context).status,
              items: [LU.of(context).user, LU.of(context).specialist],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: SSC.p51),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty ||
                      _phoneNumberController.text.isEmpty ||
                      _selectedStatus == null) {
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
                  backgroundColor: Palette.YELLOWBUTTON,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Text(LU.of(context).next,
                      style: const TextStyle(color: Colors.black)),
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
