// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/data/models/chat/message.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/ui/screens/chat/chat_screen.dart';
import 'package:urven/ui/screens/navigation.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/local_asset_image.dart';
import 'package:urven/utils/primitive/string_utils.dart';
import 'package:urven/utils/screen_size_configs.dart';
import 'package:urven/utils/lu.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    Key? key,
    required this.isBackButtonVisible,
    this.title,
    this.onBackPressed,
  }) : super(key: key);

  // ignore: constant_identifier_names
  static const double BACK_ICON_SIZE = SSC.p24;
  // ignore: constant_identifier_names
  static const double BACK_ICON_OFFSET = SSC.p5;

  final bool isBackButtonVisible;
  final String? title;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SSC.p80,
      color: Palette.BACKGROUND,
      padding: EdgeInsets.fromLTRB(
        isBackButtonVisible ? SSC.p5 : SSC.p15,
        SSC.p0,
        SSC.p10,
        SSC.p0,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: SSC.p10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isBackButtonVisible)
              IconButton(
                color: Palette.MAIN,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                ),
                iconSize: BACK_ICON_SIZE,
                padding: const EdgeInsets.all(BACK_ICON_OFFSET),
                onPressed: () {
                  if (onBackPressed == null) {
                    Navigator.pop(context);
                  } else {
                    onBackPressed?.call();
                  }
                },
              )
            else
              const LocalAssetImage(
                name: 'logo-text.png',
                width: SSC.p90,
                fit: BoxFit.fitWidth,
              ),
            if (title.isNotNullOrBlank())
              Expanded(
                child: Center(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      color: Palette.DARK_BLUE,
                      fontSize: SSC.p18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: SSC.p40),
            if (!isBackButtonVisible && title == "Chats")
              InkWell(
                borderRadius: BorderRadius.circular(SSC.p8),
                child: Container(
                  padding: const EdgeInsets.all(SSC.p5),
                  child: const Icon(
                    Icons.queue,
                    color: Palette.MAIN,
                    size: SSC.p28,
                  ),
                ),
                onTap: () {
                  showMessageBottomSheet(context);
                },
              ),
            if (!isBackButtonVisible && title != "Chats")
              InkWell(
                borderRadius: BorderRadius.circular(SSC.p8),
                child: Container(
                  padding: const EdgeInsets.all(SSC.p5),
                  child: const Icon(
                    Icons.person,
                    color: Palette.MAIN,
                    size: SSC.p28,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, Navigation.EDIT_USER_PROFILE);
                },
              ),
          ],
        ),
      ),
    );
  }
}

void showMessageBottomSheet(BuildContext context) {
  List<UserProfile> selectedUsers = [];
  bool isSelecting = false;
  String searchQuery = '';

  ooBloc.getAllUsers();

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
                      LU.of(context).select_user_to_message,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Palette.MAIN,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isSelecting ? Icons.check_circle : Icons.select_all,
                        color: Palette.MAIN,
                      ),
                      onPressed: () {
                        setState(() {
                          isSelecting = !isSelecting;
                          selectedUsers.clear();
                        });
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          LU.of(context).no_users_found,
                          style: TextStyle(color: Palette.MAIN),
                        ),
                      );
                    }

                    List<UserProfile> users = snapshot.data!;
                    users = users
                        .where((user) =>
                            user.id != ooBloc.userProfileSubject.value?.id &&
                            user.fullName!.toLowerCase().contains(searchQuery))
                        .toList();
                    return Expanded(
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                if (isSelecting)
                                  ...users.map((user) {
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      child: CheckboxListTile(
                                        activeColor: Palette.MAIN,
                                        title: Text(
                                          user.fullName!,
                                          style: TextStyle(color: Palette.MAIN),
                                        ),
                                        value: selectedUsers.contains(user),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedUsers.add(user);
                                            } else {
                                              selectedUsers.remove(user);
                                            }
                                          });
                                        },
                                      ),
                                    );
                                  }).toList()
                                else
                                  ...users.map((user) {
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      child: ListTile(
                                          title: Text(
                                            user.fullName!,
                                            style:
                                                TextStyle(color: Palette.MAIN),
                                          ),
                                          onTap: () async {
                                            if (!isSelecting) {
                                              Navigator.pop(context);
                                              ChatRoom? existingChatRoom =
                                                  await ooBloc
                                                      .getExistingPrivateChatRoom(
                                                          user.id!);
                                              if (existingChatRoom != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatScreen(
                                                            chatRoomId:
                                                                existingChatRoom
                                                                    .id!),
                                                  ),
                                                ).then((_) async {
                                                  await ooBloc.getChatRooms();
                                                  await ooBloc
                                                      .getChatRoomMessages(
                                                          existingChatRoom.id!);
                                                });
                                              } else {
                                                // Create the new chat room
                                                String roomName =
                                                    '${ooBloc.userProfileSubject.value?.fullName}:${user.fullName!}';
                                                String roomDescription =
                                                    '${ooBloc.userProfileSubject.value?.id}:${user.id!}';

                                                ChatRoom newChatRoom =
                                                    await ooBloc.createChatRoom(
                                                  roomName,
                                                  roomDescription,
                                                  "private",
                                                  [user.id!],
                                                );

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatScreen(
                                                            chatRoomId:
                                                                newChatRoom
                                                                    .id!),
                                                  ),
                                                ).then((_) async {
                                                  await ooBloc.getChatRooms();
                                                  List<Message> messages =
                                                      await ooBloc
                                                          .getChatRoomMessages(
                                                              newChatRoom.id!);
                                                  if (messages.isEmpty) {
                                                    await ooBloc.deleteChatRoom(
                                                        newChatRoom.id!);
                                                    await ooBloc
                                                        .getChatRooms(); // Refresh the chat rooms list after deletion
                                                  }
                                                });
                                              }
                                            }
                                          }),
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
                if (isSelecting)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Palette.MAIN),
                          onPressed: selectedUsers.isNotEmpty
                              ? () {
                                  setState(() {
                                    isSelecting = false;
                                  });
                                  showCreateChatRoomDialog(
                                      context, selectedUsers);
                                }
                              : null,
                          child: Text(LU.of(context).start_messaging),
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

void showCreateChatRoomDialog(
    BuildContext context, List<UserProfile> selectedUsers) {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(LU.of(context).create_chat_room,
            style: TextStyle(color: Palette.MAIN)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Chat Room Name',
                labelStyle: TextStyle(color: Palette.MAIN),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Palette.MAIN),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Palette.MAIN, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Chat Room Description',
                labelStyle: TextStyle(color: Palette.MAIN),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Palette.MAIN),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Palette.MAIN, width: 2.0),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  primary: Palette.MAIN,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text(LU.of(context).action_cancel,
                    style: TextStyle(color: Palette.MAIN)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {
                    List<int> chosenMembers =
                        selectedUsers.map((user) => user.id!).toList();
                    // Assuming ooBloc is defined and createChatRoom is a method of it
                    ooBloc.createChatRoom(nameController.text,
                        descriptionController.text, "group", chosenMembers);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
                child: Text(LU.of(context).finish),
                style: ElevatedButton.styleFrom(
                  primary: Palette.MAIN,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
