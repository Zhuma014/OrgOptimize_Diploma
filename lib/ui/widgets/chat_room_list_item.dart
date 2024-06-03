// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/utils/screen_size_configs.dart';

class ChatRoomListItem extends StatelessWidget {
  final ChatRoom chatRoom;
  final VoidCallback onTap;

  const ChatRoomListItem({
    super.key,
    required this.chatRoom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: SSC.p16, vertical: SSC.p8),
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
