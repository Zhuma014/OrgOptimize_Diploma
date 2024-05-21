import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/chat/chat_room_member.dart';
import 'package:urven/data/models/chat/message.dart';
import 'package:urven/data/models/user/user_profile.dart';

class ChatScreen extends StatefulWidget {
  final int chatRoomId;

  ChatScreen({required this.chatRoomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    ooBloc.getChatRoomMessages(widget.chatRoomId); // Fetch messages when the screen is initialized
    ooBloc.getChatRoomMembers(widget.chatRoomId); // Fetch members when the screen is initialized
  }

  Future<String> _getMemberName(int userId) async {
    UserProfile? userProfile = await ooBloc.getUserProfileById(userId);
    return userProfile?.fullName ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: ooBloc.getMessagesListSubject.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Messages'));
                }

                List<Message> messages = snapshot.data!;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Message message = messages[index];
                    return ListTile(
                      title: Text(message.content ?? 'No Content'),
                      subtitle: Text('User: ${message.userId}'),
                    );
                  },
                );
              },
            ),
          ),
          StreamBuilder<List<ChatRoomMember>>(
            stream: ooBloc.getChatRoomMembersSubject.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No Members'));
              }

              List<ChatRoomMember> members = snapshot.data!;

              return Column(
                children: [
                  ListTile(
                    title: Text('Members: ${members.length}'),
                    subtitle: FutureBuilder<List<String>>(
                      future: Future.wait(members.map((member) => _getMemberName(member.userId!))),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('Loading...');
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('No Members');
                        }

                        List<String> memberNames = snapshot.data!;
                        return Text(memberNames.join(', '));
                      },
                    ),
                  ),
                ],
              );
            },
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