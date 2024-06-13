// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/internal/bloc/cubits/bottom_nav_bar_bloc.dart';
import 'package:urven/ui/screens/chat/chat_list_screen.dart';
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
   
   return WillPopScope(
      onWillPop: () async {
        if (selectedIndex != 0) {
          context.read<BottomNavBarCubit>().changeSelectedIndex(0);
          return false;
        } else {
          return true;
        }
      },
      child: BlocBuilder<BottomNavBarCubit, int>(
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
                selectedIcon: const Icon(Icons.home, color: Colors.white),
                icon: const Icon(Icons.home_outlined),
                label: LU.of(context).home,
              ),
              NavigationDestination(
                selectedIcon: const Icon(Icons.chat, color: Colors.white),
                icon: const Icon(Icons.chat_bubble_outline),
                label: LU.of(context).chat,
              ),
              NavigationDestination(
                selectedIcon: const Icon(Icons.menu, color: Colors.white),
                icon: const Icon(Icons.menu),
                label: LU.of(context).menu,
              ),
            ],
          ),
        );
      }),
    );
   
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatListScreen(),
    const UserProfileScreen()
  ];
}
