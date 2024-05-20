// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/internal/bloc/cubits/bottom_nav_bar_bloc.dart';
import 'package:urven/ui/screens/chat_list_screen.dart';
import 'package:urven/ui/screens/events_board_screen.dart';
import 'package:urven/ui/screens/home_screen.dart';
import 'package:urven/ui/screens/profile_screen.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  @override
  void initState() {
    super.initState();

    if (PreferencesManager.instance.isAuthenticated()) {
      ooBloc.getUserProfile();
    }
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    SSC().init(context);
    return BlocBuilder<BottomNavBarCubit, int>(
        builder: (context, selectedIndex) {
      return Scaffold(
        body: _screens[selectedIndex],
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            context.read<BottomNavBarCubit>().changeSelectedIndex(index);
          },
          indicatorColor: Palette.MAIN,
          backgroundColor: Palette.BACKGROUND,
          selectedIndex: selectedIndex,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: const Icon(Icons.home),
              icon: const Icon(Icons.home_outlined),
              label: LU.of(context).home,
            ),
            NavigationDestination(
              selectedIcon: const Icon(Icons.calendar_month_sharp),
              icon: const Icon(Icons.calendar_month_sharp),
              label: LU.of(context).calendar,
            ),
            NavigationDestination(
              selectedIcon: const Icon(Icons.chat),
              icon: const Icon(Icons.chat_bubble_outline),
              label: LU.of(context).chat,
            ),
            NavigationDestination(
              selectedIcon: const Icon(Icons.account_circle_rounded),
              icon: const Icon(Icons.account_circle_outlined),
              label: LU.of(context).profile,
            ),
          ],
        ),
      );
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventsBoardScreen(),
    const ChatListScreen(),
    const UserProfileScreen()
  ];
}