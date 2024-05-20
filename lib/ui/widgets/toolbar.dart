// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/local_asset_image.dart';
import 'package:urven/utils/primitive/string_utils.dart';
import 'package:urven/utils/screen_size_configs.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    Key? key,
    required this.isBackButtonVisible,
    this.title,
    this.onBackPressed,
  }) : super(key: key);

  // ignore: constant_identifier_names
  static const double BACK_ICON_SIZE = SSC.p24;
  // ignore: constant_identifier_names
  static const double BACK_ICON_OFFSET = SSC.p5;

  final bool isBackButtonVisible;
  final String? title;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SSC.p80,
      color: Palette.BACKGROUND, // Set background color to Palette.MAIN
      padding: EdgeInsets.fromLTRB(
        isBackButtonVisible ? SSC.p5 : SSC.p15,
        SSC.p0,
        SSC.p10,
        SSC.p0,
      ),
      child: Row(
        // Adjust mainAxisAlignment for even spacing
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isBackButtonVisible)
            IconButton(
              color: Palette.MAIN,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
              ),
              iconSize: BACK_ICON_SIZE,
              padding: const EdgeInsets.all(BACK_ICON_OFFSET),
              onPressed: () {
                if (onBackPressed == null) {
                  Navigator.pop(context);
                } else {
                  onBackPressed?.call();
                }
              },
            )
          else
            const LocalAssetImage(
              name: 'image.png',
              height: 80,
              fit: BoxFit.cover,
            ),
          if (title.isNotNullOrBlank())
            Expanded( // Use Expanded to fill remaining space
              child: Center(
                child: Text(
                  title!,
                  style: const TextStyle(
                    color: Palette.DARK_BLUE,
                    fontSize: SSC.p18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40),
          // Conditionally show notification button
          if (!isBackButtonVisible) // Only show if back button is hidden
            InkWell(
              borderRadius: BorderRadius.circular(SSC.p8),
              child: Container(
                padding: const EdgeInsets.all(SSC.p5),
                child: const Icon(
                  Icons.notifications,
                  color: Palette.MAIN,
                  size: SSC.p28,
                ),
              ),
              onTap: () {
                // SignInDialog(
                //   // ... your code here
                // ).showSignInDialog(context);
              },
            ),
        ],
      ),
    );
  }
}


