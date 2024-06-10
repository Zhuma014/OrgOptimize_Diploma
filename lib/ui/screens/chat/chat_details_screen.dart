// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/data/models/chat/chat_room_member.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/common_dialog.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    ooBloc.getChatRooms();
    _nameController = TextEditingController(text: widget.chatRoom.name);
    _descriptionController =
        TextEditingController(text: widget.chatRoom.description);
    ooBloc.getChatRoomMembers(widget.chatRoom.id!);
    ooBloc.getUserProfile();

  }

  

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateChatRoom({List<int>? chosenMembers}) async {
    if (_formKey.currentState!.validate()) {
      ChatRoom? updatedChatRoom = await ooBloc.updateChatRoom(
        roomId: widget.chatRoom.id!,
        name: _nameController.text,
        description: _descriptionController.text,
        type: widget.chatRoom.type!,
        chosen_members: chosenMembers,
      );

      if (updatedChatRoom != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chat room updated successfully'),
            backgroundColor: Palette.MAIN,
          ),
        );
        setState(() {
          widget.chatRoom.name = _nameController.text;
          
        });
         ooBloc
          .getChatRoomMembers(widget.chatRoom.id!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update chat room'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _changeChatRoomOwner(int newOwnerId) async {
    await ooBloc.changeChatRoomOwner(widget.chatRoom.id!, newOwnerId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chat room owner changed successfully!'),
          backgroundColor: Palette.MAIN,
        ),
      );
      ooBloc
          .getChatRoomMembers(widget.chatRoom.id!); // Fetch the updated members
    });
  }

  void _deleteChatRoomMember(int memberId) async {
    await ooBloc.deleteChatRoomMember(widget.chatRoom.id!, memberId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member deleted successfully!'),
          backgroundColor: Palette.MAIN,
        ),
      );
      ooBloc
          .getChatRoomMembers(widget.chatRoom.id!); // Fetch the updated members
    });
  }

  void _deleteChatRoom(int chatRoomId) async {
    showCustomDialog(
      context: context,
      title: 'Delete Chat Room',
      description:
          'Are you sure you want to delete this chat room? Please change the owner',
      positiveText: 'Delete anyway',
      negativeText: 'Cancel',
      onPositivePressed: () async {
        Navigator.pop(context);
        await ooBloc.deleteChatRoom(chatRoomId).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Chat room deleted successfully!'),
                backgroundColor: Colors.red),
          );
        });
      },
    );
  }

  void _leaveChatRoom(int chatRoomId) async {
    showCustomDialog(
      context: context,
      title: 'Leave Chat Room',
      description: 'Are you sure you want to leave this chat room?',
      positiveText: 'Leave',
      negativeText: 'Cancel',
      onPositivePressed: () async {
        Navigator.pop(context);

        await ooBloc.leaveChatRoom(chatRoomId).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Chat room left successfully!'),
                backgroundColor: Colors.red),
          );
        });
      },
    );
  }

 void showMessageBottomSheet(BuildContext context) {
  List<UserProfile> selectedUsers = [];
  String searchQuery = '';

  ooBloc.getAllUsers();
  ooBloc.getChatRoomMembers(widget.chatRoom.id!);

  showModalBottomSheet(
    context: context,
    backgroundColor: Palette.BACKGROUND,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    Text(
                      'Select users to add',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Palette.MAIN,
                      ),
                    ),
                                        IconButton(
                            icon: Icon(Icons.cancel, color: Palette.MAIN),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                  ],
                ),
                SizedBox(height: 5),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter a name',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: Palette.MAIN),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
                SizedBox(height: 5),
                StreamBuilder<List<UserProfile>>(
                  stream: ooBloc.usersSubject,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    List<UserProfile> users = snapshot.data ?? [];
                    List<int> chatRoomMemberIds = [];
                    List<ChatRoomMember> chatRoomMembers =
                        ooBloc.getChatRoomMembersSubject.value ?? [];

                    chatRoomMemberIds =
                        chatRoomMembers.map((member) => member.id!).toList();

                    List<UserProfile> filteredUsers = users
                        .where((user) =>
                            !chatRoomMemberIds.contains(user.id) &&
                            user.id != ooBloc.userProfileSubject.value?.id &&
                            user.fullName!.toLowerCase().contains(searchQuery))
                        .toList();

                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Text(
                          'All users are in this chat room.',
                          style: TextStyle(color: Palette.MAIN),
                        ),
                      );
                    }

                    return Expanded(
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                ...filteredUsers.map((user) {
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    child: CheckboxListTile(
                                      title: Text(
                                        user.fullName!,
                                        style: TextStyle(color: Palette.MAIN),
                                      ),
                                      value: selectedUsers.contains(user),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value!) {
                                            selectedUsers.add(user);
                                          } else {
                                            selectedUsers.remove(user);
                                          }
                                        });
                                      },
                                        activeColor: Palette.MAIN,
                                        

                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: selectedUsers.isNotEmpty
                              ? Palette.MAIN
                              : Colors.grey,
                        ),
                        onPressed: selectedUsers.isNotEmpty
                            ? () {
                                _updateChatRoom(
                                    chosenMembers: selectedUsers
                                        .map((user) => user.id!)
                                        .toList());
                                Navigator.of(context).pop();
                              }
                            : null,
                        child: Text('Add Selected Users'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    var currentUserProfile = ooBloc.userProfileSubject.value;
    bool currentUserIsOwner = widget.chatRoom.ownerId == currentUserProfile?.id;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.chatRoom.name ?? 'Chat Details'),
        backgroundColor: Palette.MAIN,
        actions: [
          if (currentUserIsOwner &&
              (widget.chatRoom.type == 'group' ||
                  widget.chatRoom.type == 'main' ||
                  widget.chatRoom.type == 'general'))
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _updateChatRoom,
            ),
          if (currentUserIsOwner)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showMessageBottomSheet(context);
              },
            ),
        ],
      ),
      body: widget.chatRoom.type == 'private'
          ? Center(child: Text('No details available for private chats.'))
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Chat Room Name',
                        labelStyle: TextStyle(color: Palette.MAIN),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Palette.MAIN),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a chat room name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Palette.MAIN),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Palette.MAIN),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Members',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Palette.MAIN),
                    ),
                    Expanded(
                      child: StreamBuilder<List<ChatRoomMember>>(
                        stream: ooBloc.getChatRoomMembersSubject,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                                    color: Palette.MAIN));
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}',
                                    style: TextStyle(color: Colors.red)));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(child: Text('No members found.'));
                          }
                    
                          List<ChatRoomMember> members = snapshot.data!;
                          return ListView.builder(
                              shrinkWrap: true, // Add this line
                    
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              ChatRoomMember member = members[index];
                              bool isCurrentUser =
                                  member.id == currentUserProfile?.id;
                              return ListTile(
                                title: Text(member.fullName!),
                                subtitle: Text(member.role!),
                                trailing: (!isCurrentUser && currentUserIsOwner)
    ? PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'delete') {
            showCustomDialog(
              context: context,
              title: 'Delete Member',
              description: 'Are you sure you want to delete this member?',
              positiveText: 'Delete',
              negativeText: 'Cancel',
              onPositivePressed: () {
                _deleteChatRoomMember(member.id!);
              },
              onNegativePressed: () {
                // Optionally handle the cancel action here
              },
              positiveButtonColor: Colors.red, // Set the color for the positive button
            );
          } else if (value == 'change_owner') {
            showCustomDialog(
              context: context,
              title: 'Change Owner',
              description: 'Are you sure you want to make this member the owner?',
              positiveText: 'Change Owner',
              negativeText: 'Cancel',
              onPositivePressed: () {
                _changeChatRoomOwner(member.id!);
                Navigator.pop(context); // Dismiss the popup menu
                Navigator.pop(context); // Dismiss the previous screen
              },
              onNegativePressed: () {
                // Optionally handle the cancel action here
              },
              positiveButtonColor: Palette.MAIN, // Set the color for the positive button
            );
          }
        },
        itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          const PopupMenuItem<String>(
            value: 'change_owner',
            child: Text('Make Owner', style: TextStyle(color: Palette.MAIN)),
          ),
        ],
      )
    : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                                      SizedBox(height: 16), // Add some space between the list and the button

     SizedBox(
      width: double.infinity,
       child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                if (currentUserIsOwner) {
                  // Logic for deleting the chat room
                  _deleteChatRoom(widget.chatRoom.id!);
                } else {
                  // Logic for leaving the chat room
                  _leaveChatRoom(widget.chatRoom.id!);
                }
              },
              child: Text(
                currentUserIsOwner ? 'Delete Chat Room' : 'Leave Chat Room',
              ),
            ),
     ),
      ],
                ),
              ),
            ),
    );
  }
}
