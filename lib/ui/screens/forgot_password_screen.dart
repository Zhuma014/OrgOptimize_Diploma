import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/ui/screens/confirm_email_screen.dart';
import 'package:urven/ui/screens/reset_password_screen.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/text_field.dart';
import 'package:urven/utils/email_utils.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/password_utils.dart';
import 'package:urven/utils/screen_size_configs.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.BACKGROUND,
      body: Builder(
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: SSC.p172),
                  Text(
                    "Please, enter your email",
                    style: const TextStyle(
                        color: Palette.MAIN,
                        fontSize: SSC.p20,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: SSC.p108),
                  RoundedTextField(
                    labelText: "Email",
                    controller: _emailController,
                  ),
                  const SizedBox(height: SSC.p145),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_emailController.text == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(LU.of(context).please_fill_all_fields),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (!_emailController.text.isEmail()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(LU.of(context).enter_correct_email),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        bool isEmailSent =
                            await ooBloc.resetPassword(_emailController.text);
                        print("WERTYUIWDNMK $isEmailSent");

                        if (!isEmailSent) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("User not found"),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResetPasswordScreen(),
                            ),
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
                        child: Text("Send reset password link",
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: SSC.p20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
