// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/ui/screens/chat/chat_rooms_screen.dart';
import 'package:urven/ui/screens/navigation.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/toolbar.dart';


class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    ooBloc.getUserClubs(); // Fetch clubs when the screen is initialized
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Toolbar(
              isBackButtonVisible: false,
              title: 'Chats',
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Club>>(
              stream: ooBloc.getUserClubsSubject,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You are not member of any club'),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Palette.MAIN),
                onPressed: () {
                  // Navigate to the allClubsScreen
                  Navigator.pushNamed(context, Navigation.ALLCLUBS);
                },
                child: const Text('Join Clubs'),
              ),
            ],
          ),
        );                }

                List<Club> clubs = snapshot.data!;

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    Club club = clubs[index];
                    return ClubListItem(
                      club: club,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomsScreen(clubId: club.id!),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    ooBloc.dispose(); // Clean up the stream subscriptions
  }
}



class ClubListItem extends StatelessWidget {
  final Club club;
  final VoidCallback onTap;

  const ClubListItem({super.key, required this.club, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: const CircleAvatar(
        radius: 24.0,
        backgroundImage: AssetImage(              'assets/images/image.png',
),
      ),
      title: Text(
        club.name ?? 'Unnamed Club',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(club.description ?? ''),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
