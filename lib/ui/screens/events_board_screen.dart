// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
// import 'package:urven/data/preferences/preferences_manager.dart';
// import 'package:urven/ui/screens/authentication_screen.dart';
import 'package:urven/ui/screens/base/base_screen.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/lu.dart';
// import 'package:urven/ui/widgets/profile_menu_option.dart';
// import 'package:urven/utils/lu.dart';

class EventsBoardScreen extends StatefulWidget {
  const EventsBoardScreen({super.key});

  @override
  EventsBoardScreenState createState() => EventsBoardScreenState();
}

class EventsBoardScreenState extends BaseScreenState<EventsBoardScreen> {
  @override
  void initState() {
    super.initState();
  }
    @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Toolbar(
                isBackButtonVisible: false,
                title: 
                  LU.of(context).calendar
                ),
          ),
        ],
      ),
    );
  }

}
