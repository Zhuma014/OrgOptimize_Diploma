// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/ui/screens/chat/chat_screen.dart';
import 'package:urven/ui/widgets/toolbar.dart';


class ChatRoomsScreen extends StatefulWidget {
  final int clubId;

  const ChatRoomsScreen({super.key, required this.clubId});

  @override
  _ChatRoomsScreenState createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  @override
  void initState() {
    super.initState();
    ooBloc.getChatRooms(); // Fetch chat rooms when the screen is initialized
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
              isBackButtonVisible: true, // Enable back button for this screen
              title: 'Chat Rooms',
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChatRoom>>(
              stream: ooBloc.getChatRoomsSubject,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Chat Rooms Available'));
                }

                List<ChatRoom> chatRooms = snapshot.data!
                    .where((chatRoom) => chatRoom.clubId == widget.clubId)
                    .toList();

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    ChatRoom chatRoom = chatRooms[index];

                    return ChatRoomListItem(
                      chatRoom: chatRoom,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(chatRoomId: chatRoom.id!),
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



class ChatRoomListItem extends StatelessWidget {
  final ChatRoom chatRoom;
  final VoidCallback onTap;

  const ChatRoomListItem({super.key, 
    required this.chatRoom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      title: Text(
        chatRoom.name ?? 'Unnamed Chat Room',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(chatRoom.description ?? ''),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
