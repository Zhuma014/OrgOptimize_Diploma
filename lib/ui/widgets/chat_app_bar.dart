// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/data/models/chat/chat_room_member.dart';
import 'package:urven/ui/screens/chat/chat_details_screen.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/screen_size_configs.dart';
import 'package:urven/utils/lu.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int chatRoomId;

  const ChatAppBar({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _navigateToChatDetails(context);
      },
      child: AppBar(
        backgroundColor: Palette.MAIN,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<List<ChatRoom>>(
              stream: ooBloc.getChatRoomsSubject,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    LU.of(context).loading,
                    style: const TextStyle(fontSize: SSC.p14, fontWeight: FontWeight.bold),
                  );
                } else if (snapshot.hasError) {
                  print('Error fetching chat rooms: ${snapshot.error}');
                  return Text(
                    LU.of(context).error_occured,
                    style: const TextStyle(fontSize: SSC.p14, fontWeight: FontWeight.bold),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    LU.of(context).default_chat_room,
                    style: const TextStyle(fontSize: SSC.p14, fontWeight: FontWeight.bold),
                  );
                } else {
                  ChatRoom? chatRoom = snapshot.data!.firstWhere(
                    (room) => room.id == chatRoomId,
                    orElse: () => ChatRoom(id: -1, name: LU.of(context).default_chat_room),
                  );

                  if (chatRoom.type == 'private') {
                    List<String> memberNames = chatRoom.name?.split(':') ?? [];
                    memberNames.removeWhere((name) => name.trim().isEmpty);

                    String? neighborName;
                    if (ooBloc.userProfileSubject.value?.fullName == memberNames[0]) {
                      neighborName = memberNames[1];
                    } else if (ooBloc.userProfileSubject.value?.fullName == memberNames[1]) {
                      neighborName = memberNames[0];
                    }

                    return Text(
                      neighborName ?? LU.of(context).default_chat_room,
                      style: const TextStyle(fontSize: SSC.p16, fontWeight: FontWeight.bold),
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chatRoom.name ?? LU.of(context).default_chat_room,
                          style: const TextStyle(fontSize: SSC.p16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: SSC.p4),
                        StreamBuilder<List<ChatRoomMember>>(
                          stream: ooBloc.getChatRoomMembersSubject,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text(
                                LU.of(context).loading,
                                style: const TextStyle(fontSize: SSC.p12),
                              );
                            } else if (snapshot.hasError) {
                              print('Error fetching chat room members: ${snapshot.error}');
                              return const Text(
                                'Error fetching members',
                                style: TextStyle(fontSize: SSC.p12),
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Text(
                                LU.of(context).no_members_found,
                                style: const TextStyle(fontSize: SSC.p12),
                              );
                            } else {
                              final memberNames = snapshot.data!
                                  .map((member) => member.fullName ?? 'Unknown')
                                  .toList();
                              return Text(
                                '${LU.of(context).members}: ${memberNames.join(', ')}',
                                style: const TextStyle(fontSize: SSC.p12),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChatDetails(BuildContext context) async {
    List<ChatRoom>? chatRooms = ooBloc.getChatRoomsSubject.valueOrNull;

    if (chatRooms != null) {
      ChatRoom? chatRoom = chatRooms.firstWhere(
        (room) => room.id == chatRoomId,
      );

      if (chatRoom.type != 'private') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailsScreen(chatRoom: chatRoom),
          ),
        );
      }
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
