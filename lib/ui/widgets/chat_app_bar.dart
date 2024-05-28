// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/data/models/chat/chat_room_member.dart';
import 'package:urven/ui/theme/palette.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int chatRoomId;

  const ChatAppBar({super.key, required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Palette.MAIN,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<List<ChatRoom>>(
            stream: ooBloc.getChatRoomsSubject,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text(
                  'Loading...',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                );
              } else if (snapshot.hasError) {
                print('Error fetching chat rooms: ${snapshot.error}');
                return const Text(
                  'Error',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text(
                  'Default Chat Room',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                );
              } else {
                ChatRoom? chatRoom = snapshot.data!.firstWhere(
                  (room) => room.id == chatRoomId,
                  orElse: () => ChatRoom(id: -1, name: 'Default Chat Room'),
                );
                return Text(
                  chatRoom.name ?? 'Default Chat Room',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                );
              }
            },
          ),
          const SizedBox(height: 4),
          StreamBuilder<List<ChatRoomMember>>(
            stream: ooBloc.getChatRoomMembersSubject,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text(
                  'Loading members...',
                  style: TextStyle(fontSize: 12),
                );
              } else if (snapshot.hasError) {
                print('Error fetching chat room members: ${snapshot.error}');
                return const Text(
                  'Error fetching members',
                  style: TextStyle(fontSize: 12),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text(
                  'No members',
                  style: TextStyle(fontSize: 12),
                );
              } else {
                final memberNames = snapshot.data!
                    .map((member) => member.fullName ?? 'Unknown')
                    .toList();
                return Text(
                  'Members: ${memberNames.join(', ')}',
                  style: const TextStyle(fontSize: 12),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
