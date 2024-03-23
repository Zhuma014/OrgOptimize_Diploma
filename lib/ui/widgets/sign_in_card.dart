// ignore_for_file: library_private_types_in_public_api

// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/ui/screens/forgot_password.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/email_utils.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/text_field.dart';
import 'package:urven/utils/screen_size_configs.dart';

class SignInCard extends StatefulWidget {
  const SignInCard({super.key});

  @override
  _SignInCardState createState() => _SignInCardState();
}

class _SignInCardState extends State<SignInCard> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            const SizedBox(height: SSC.p35),
            Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 19),
                  ),
                ),
                child: Text(
                  LU.of(context).forgot_password,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: SSC.p14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SSC.p35),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
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
                  } else {
                    //success
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(LU.of(context).success),
                        duration: const Duration(seconds: 2),
                      ),
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
                  child: Text(
                    LU.of(context).next,
                    style: const TextStyle(color: Colors.black),
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
