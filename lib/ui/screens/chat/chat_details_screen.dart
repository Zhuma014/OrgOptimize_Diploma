
// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:urven/data/models/user/user_profile.dart';

class ChatDetailsScreen extends StatefulWidget {
  final int chatRoomId;

  const ChatDetailsScreen({super.key, required this.chatRoomId});

  @override
  _ChatDetailsScreenState createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  late Stream<List<UserProfile>> _chatRoomMembersStream;

  @override
  void initState() {
    super.initState();
    // _chatRoomMembersStream = _getChatRoomMembersStream(widget.chatRoomId);
  }

  // Stream<List<UserProfile>> _getChatRoomMembersStream(int roomId) {
  //   return ooBloc.getChatRoomMembersSubject.stream.asyncMap((chatRoomMembers) async {
  //     List<int> userIds = chatRoomMembers.map((member) => member.userId ?? -1).toList();
  //     List<UserProfile> profiles = await Future.wait(userIds.map((userId) => ooBloc.getUserProfileById(userId)));
  //     return profiles;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<UserProfile>>(
          stream: _chatRoomMembersStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching members'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No members'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  UserProfile profile = snapshot.data![index];
                  return ListTile(
                    title: Text(profile.fullName ?? 'Unknown'),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
