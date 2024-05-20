// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/internal/bloc/cubits/bottom_nav_bar_bloc.dart';
import 'package:urven/ui/screens/navigation.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/logger.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/ui/widgets/text_field.dart';

class SignInCard extends StatefulWidget {
  const SignInCard({Key? key}) : super(key: key);

  @override
  _SignInCardState createState() => _SignInCardState();
}

class _SignInCardState extends State<SignInCard> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 20),
            RoundedTextField(
              labelText: LU.of(context).email,
              controller: _usernameController,
            ),
            const SizedBox(height: 18),
            RoundedTextField(
              labelText: LU.of(context).password,
              obscureText: true,
              controller: _passwordController,
              // Add accessibility label for screen readers
            ),
            const SizedBox(height: 35),
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
                    const EdgeInsets.symmetric(horizontal: 19),
                  ),
                ),
                child: Text(
                  LU.of(context).forgot_password,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_usernameController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(LU.of(context).please_fill_all_fields),
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
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Text(
                    LU.of(context).login,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _performSignIn() {
    String username = _usernameController.text.trim().replaceAll(' ', '');
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          duration:  Duration(seconds: 2),
        ),
      );
      return;
    }
    ooBloc.signIn(username, password);

    ooBloc.signInSubject.stream.listen((value) {
      Logger.d('SignInCard',
          'ssBloc.signInSubject.stream.listen() -> ${value.isValid}');


      if (value.isValid) {
        _usernameController.clear();
        _passwordController.clear();
                 Navigator.pushNamed(context, Navigation.HOME);
                     context.read<BottomNavBarCubit>().changeSelectedIndex(0);


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign In Failed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
