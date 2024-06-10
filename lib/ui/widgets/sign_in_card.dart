// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/internal/bloc/cubits/bottom_nav_bar_bloc.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/logger.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/ui/widgets/text_field.dart';
import 'package:urven/utils/screen_size_configs.dart';
import 'package:urven/wrapper.dart';

class SignInCard extends StatefulWidget {
  const SignInCard({Key? key}) : super(key: key);

  @override
  _SignInCardState createState() => _SignInCardState();
}

class _SignInCardState extends State<SignInCard> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SSC.p28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: SSC.p20),
            RoundedTextField(
              labelText: LU.of(context).email,
              controller: _usernameController,
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
                      builder: (context) => const SignInCard(),
                    ),
                  );
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: SSC.p19),
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
            _isLoading
             ? const Center(
                child: CircularProgressIndicator(color: Palette.MAIN,),
              )
           : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_usernameController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(LU.of(context).please_fill_all_fields),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  _performSignIn();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.MAIN,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SSC.p25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: SSC.p12),
                  child: Text(
                    LU.of(context).login,
                    style: const TextStyle(
                        color: Palette.BACKGROUND,
                        fontWeight: FontWeight.w600,
                        fontSize: SSC.p16),
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

  void _performSignIn() {
    String username = _usernameController.text.trim().replaceAll(' ', '');
    String password = _passwordController.text;
    String? fcmToken = PreferencesManager.instance.getFirebaseMessagingToken();

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill in all fields'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

    ooBloc.signIn(username, password, fcm_token: fcmToken!);

  ooBloc.signInSubject.stream.listen((value) {
    Logger.d('SignInCard', 'ooBloc.signInSubject.stream.listen() -> ${value.isValid}');

      if (value.isValid) {
        _usernameController.clear();
        _passwordController.clear();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainWrapper()),
          (route) => false,
        );

      context.read<BottomNavBarCubit>().changeSelectedIndex(0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value.exception ?? 'Sign In Failed'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  });
}

}
