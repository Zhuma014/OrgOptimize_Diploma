// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/screen_size_configs.dart';

class ProfileMenuOption extends StatelessWidget {
  const ProfileMenuOption({super.key, 
    required this.title,
    required this.onPressed,
  });

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Ink(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SSC.p15,
            SSC.p15,
            SSC.p15,
            SSC.p0,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Palette.DARK_BLUE,
                      fontSize: SSC.p16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: Palette.DARK_GREY_2,
                    size: SSC.p25,
                  ),
                ],
              ),
              const SizedBox(height: SSC.p15),
              const Divider(
                color: Palette.SOLITUDE,
                height: 1,
                thickness: SSC.p1_3,
              )
            ],
          ),
        ),
      ),
    );
  }
}
