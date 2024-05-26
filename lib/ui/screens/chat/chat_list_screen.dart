import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/ui/screens/chat/chat_rooms_screen.dart';
import 'package:urven/ui/screens/chat/chat_screen.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/lu.dart';
import 'package:flutter/material.dart';


class ChatListScreen extends StatefulWidget {
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
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Toolbar(
              isBackButtonVisible: false,
              title: 'Chats',
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Club>>(
              stream: ooBloc.getUserClubsSubject.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Clubs Available'));
                }

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

  ClubListItem({required this.club, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        radius: 24.0,
        backgroundImage: AssetImage(              'assets/images/image.png',
),
      ),
      title: Text(
        club.name ?? 'Unnamed Club',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(club.description ?? ''),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
