import 'dart:async';

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/network/repository/api_repository.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/text_field.dart';
import 'package:confetti/confetti.dart';
import 'package:urven/wrapper.dart';

class ResetPasswordScreen extends StatefulWidget {
  ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
   

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();



  }

  @override
  void dispose() {
    _controller.dispose();
   
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.BACKGROUND,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _animation,
                    child: Icon(
                      Icons.email,
                      color: Palette.DARK_BLUE,
                      size: 100,
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _animation,
                    child: Text(
                      "Check your mail",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Palette.DARK_BLUE,
                          fontSize: 24,
                          fontWeight: FontWeight.w600),
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