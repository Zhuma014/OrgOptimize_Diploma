// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/local_asset_image.dart';
import 'package:urven/utils/primitive/string_utils.dart';
import 'package:urven/utils/screen_size_configs.dart';

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
                name: 'image.png',
                height: SSC.p80,
                fit: BoxFit.cover,
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
                    Icons.notifications,
                    color: Palette.MAIN,
                    size: SSC.p28,
                  ),
                ),
                onTap: () {
                
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

  ooBloc.getAllUsers();

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(SSC.p8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select a user to message',
                    style: TextStyle(fontSize: 18)),
                StreamBuilder<List<UserProfile>>(
                  stream: ooBloc.usersSubject,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No users found'));
                    }

                    List<UserProfile> users = snapshot.data!;
                    users = users
                        .where((user) =>
                            user.id != ooBloc.userProfileSubject.value?.id)
                        .toList();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isSelecting = !isSelecting;
                              selectedUsers.clear();
                            });
                          },
                          child: Text(
                              isSelecting ? 'Done Selecting' : 'Select Users'),
                        ),
                        if (isSelecting)
                          ...users.map((user) {
                            return CheckboxListTile(
                              title: Text(user.fullName!),
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
                            );
                          }).toList()
                        else
                          ...users.map((user) {
                            return ListTile(
                              title: Text(user.fullName!),
                              onTap: () {
                                if (!isSelecting) {
                                  Navigator.pop(context);
                                  if (user.id != null) {
                                    selectedUsers.clear();
                                    selectedUsers.add(user);
                                    ooBloc.createChatRoom(user.fullName!, "",
                                        "private", [user.id!]);
                                  }
                                }
                              },
                            );
                          }).toList(),
                      ],
                    );
                  },
                ),
                if (isSelecting)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        onPressed: selectedUsers.isNotEmpty
                            ? () {
                                setState(() {
                                  isSelecting = false;
                                });
                                showCreateChatRoomDialog(
                                    context, selectedUsers);
                              }
                            : null,
                        child: const Text('Create Chat Room'),
                      ),
                    ],
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
        title: const Text('Create Chat Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Chat Room Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Chat Room Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                List<int> chosenMembers =
                    selectedUsers.map((user) => user.id!).toList();
                ooBloc.createChatRoom(nameController.text,
                    descriptionController.text, "group", chosenMembers);
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pop();
              }
            },
            child: const Text('Finish'),
          ),
        ],
      );
    },
  );
}
