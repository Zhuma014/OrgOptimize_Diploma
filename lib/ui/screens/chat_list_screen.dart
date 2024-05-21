import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/ui/screens/chat_screen.dart';


class ChatRoomsListScreen extends StatefulWidget {
  @override
  _ChatRoomsListScreenState createState() => _ChatRoomsListScreenState();
}

class _ChatRoomsListScreenState extends State<ChatRoomsListScreen> {
  @override
  void initState() {
    super.initState();
    ooBloc.getChatRooms(); // Fetch chat rooms when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: ooBloc.getChatRoomsSubject.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Chat Rooms Available'));
          }

          List<ChatRoom> chatRooms = snapshot.data!;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              ChatRoom chatRoom = chatRooms[index];
              return ListTile(
                title: Text(chatRoom.name ?? 'Unnamed Chat Room'),
                subtitle: Text(chatRoom.description ?? ''),
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
    );
  }

  @override
  void dispose() {
    super.dispose();
    ooBloc.dispose(); // Clean up the stream subscriptions
  }
}