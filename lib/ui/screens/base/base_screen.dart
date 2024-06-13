// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/action_button.dart';
import 'package:urven/utils/screen_size_configs.dart';
import 'package:urven/utils/lu.dart';

abstract class BaseScreenState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget buildErrorWidget(
    String body, {
    String? title,
    ActionButton? actionButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SSC.p15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title == null || title.isEmpty ? LU.of(context).error_occured : title,
              style: const TextStyle(
                color: Palette.DARK_BLUE,
                fontSize: SSC.p16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SSC.p15),
            Text(
              body,
              style: const TextStyle(
                color: Palette.DARK_BLUE,
                fontSize: SSC.p14,
                fontWeight: FontWeight.w400,
              ),
            ),
            ...buildActionButton(actionButton),
          ],
        ),
      ),
    );
  }

  List<Widget> buildActionButton(ActionButton? actionButton) {
    if (actionButton == null) return [];
    return [const SizedBox(height: SSC.p20), actionButton];
  }

  buildSnackbarErrorWidget(BuildContext context, String error) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error)));
  }

  Widget buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator()],
      ),
    );
  }
}

