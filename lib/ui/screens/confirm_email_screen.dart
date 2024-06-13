import 'dart:async';

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/network/repository/api_repository.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/text_field.dart';
import 'package:confetti/confetti.dart';
import 'package:urven/wrapper.dart';

class ConfirmEmailScreen extends StatefulWidget {
  ConfirmEmailScreen({super.key});

  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends State<ConfirmEmailScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _animation;
  late StreamSubscription<bool> _isConfirmedSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

   

    checkConfirmationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _controller.dispose();
    _isConfirmedSubscription?.cancel();
    super.dispose();
  }

  void checkConfirmationStatus() {
    ooBloc.isConfirmed();
    _isConfirmedSubscription =
        ooBloc.isConfirmedSubject.stream.listen((isConfirmed) {
      if (isConfirmed && mounted) {
        if (ModalRoute.of(context)?.isCurrent == true) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    const SizedBox(
                      width: 20,
                      height: 10,
                    ),
                    Flexible(
                      child: Text(
                        'Email confirmed successfully, after some seconds you will be in platform',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainWrapper()),
            );
          });
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      checkConfirmationStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.BACKGROUND,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _animation!,
                    child: Icon(
                      Icons.email_outlined,
                      color: Palette.DARK_BLUE,
                      size: 120,
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _animation!,
                    child: Text(
                      "Email Confirmation",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Palette.DARK_BLUE,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _animation!,
                    child: Text(
                      "We have sent a confirmation link to your email. Please confirm it to continue.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Palette.DARK_BLUE,
                        fontSize: 18,
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
