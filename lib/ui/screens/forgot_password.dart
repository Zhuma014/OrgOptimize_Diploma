// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/ui/screens/code_input_screen.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/password_utils.dart';
import 'package:urven/utils/text_field.dart';
import 'package:urven/utils/screen_size_configs.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
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
                    LU.of(context).forgot_password,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: SSC.p42,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: SSC.p108),
                  RoundedTextField(
                      labelText: LU.of(context).new_password, obscureText: true),
                  const SizedBox(height: SSC.p145),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                  if (
                      _newPasswordController.text.isEmpty
                      ) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(LU.of(context).please_fill_all_fields),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  
                  if (!_newPasswordController.text.isValidPassword()) {
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
                        child: Text(LU.of(context).save_continue,
                            style: const TextStyle(color: Colors.black)),
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
