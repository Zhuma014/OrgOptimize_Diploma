
// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/data/models/chat/chat_room_member.dart';
import 'package:urven/utils/screen_size_configs.dart';

class ChatDetailsScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatDetailsScreen({Key? key, required this.chatRoom}) : super(key: key);

  @override
  _ChatDetailsScreenState createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.chatRoom.name);
    _descriptionController = TextEditingController(text: widget.chatRoom.description);
    ooBloc.getChatRoomMembers(widget.chatRoom.id!);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateChatRoom() {
    if (_formKey.currentState!.validate()) {
      ooBloc.updateChatRoom(
        roomId: widget.chatRoom.id!,
        name: _nameController.text,
        description: _descriptionController.text,
        
      );
    }
  }

  void _deleteChatRoomMember(int memberId) {
    ooBloc.deleteChatRoomMember(widget.chatRoom.id!, memberId);
  }

  void _changeChatRoomOwner(int newOwnerId) {
    ooBloc.changeChatRoomOwner(widget.chatRoom.id!, newOwnerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoom.name ?? 'Chat Details'),
        actions: [
          if (widget.chatRoom.type == 'group' || widget.chatRoom.type == 'main'|| widget.chatRoom.type == 'general' )
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _updateChatRoom,
            ),
        ],
      ),
      body: widget.chatRoom.type == 'private'
          ? Center(child: Text('No details available for private chats.'))
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(SSC.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Chat Room Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a chat room name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    SizedBox(height: SSC.p20),
                    Text(
                      'Members',
                      style: TextStyle(fontSize: SSC.p18, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: StreamBuilder<List<ChatRoomMember>>(
                        stream: ooBloc.getChatRoomMembersSubject,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No members found.'));
                          }

                          List<ChatRoomMember> members = snapshot.data!;
                          return ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              ChatRoomMember member = members[index];
                              return ListTile(
                                title: Text(member.fullName ?? 'Unnamed Member'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteChatRoomMember(member.id!),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.star, color: Colors.amber),
                                      onPressed: () => _changeChatRoomOwner(member.id!),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}