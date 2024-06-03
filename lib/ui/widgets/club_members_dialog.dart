// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/common_dialog.dart';
import 'package:urven/utils/screen_size_configs.dart';

class ClubMembersDialog extends StatefulWidget {
  final int clubId;
  final String clubName;

  const ClubMembersDialog(
      {required this.clubId, required this.clubName, Key? key})
      : super(key: key);

  @override
  _ClubMembersDialogState createState() => _ClubMembersDialogState();
}

class _ClubMembersDialogState extends State<ClubMembersDialog> {
  late Future<List<UserProfile>> membersFuture;

  @override
  void initState() {
    super.initState();
    membersFuture = ooBloc.getClubMembers(widget.clubId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserProfile>>(
      future: membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(SSC.p50),
              child: Text('No members found in ${widget.clubName}.'),
            ),
          );
        } else {
          final members = snapshot.data!;
          return AlertDialog(
            title: Text('Members of ${widget.clubName}'),
            content: SingleChildScrollView(
              child: ListBody(
                children: members.map((member) {
                  if (member.id == ooBloc.userProfileSubject.value?.id) {
                    return ListTile(
                      title: Text(member.fullName!),
                      subtitle: Text(member.email!),
                      trailing: const Text("You"),
                    );
                  } else {
                    return ListTile(
                      title: Text(member.fullName!),
                      subtitle: Text(member.email!),
                      trailing: SizedBox(
                        width: SSC.p96,
                        height: SSC.p200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.person_add_alt_1),
                                onPressed: () {
                                  showCustomDialog(
                                    context: context,
                                    title: 'Make Admin Confirmation',
                                    description:
                                        'Are you sure you want to make this member an admin?',
                                    positiveText: 'Yes',
                                    negativeText: 'No',
                                    onPositivePressed: () {
                                      ooBloc.changeAdmin(
                                          widget.clubId, member.id!);
                                      Navigator.of(context)
                                          .pop();
                                    },
                                    onNegativePressed: () {},
                                    positiveButtonColor: Palette.MAIN,
                                    negativeButtonColor: Colors.grey,
                                  );
                                }),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showCustomDialog(
                                  context: context,
                                  title: 'Delete Member Confirmation',
                                  description:
                                      'Are you sure you want to delete this member?',
                                  positiveText: 'Yes',
                                  negativeText: 'No',
                                  onPositivePressed: () {
                                    ooBloc.deleteMember(
                                        widget.clubId, member.id!);
                                         Navigator.of(context)
                                          .pop(); 
                                  },
                                  onNegativePressed: () {},
                                     positiveButtonColor: Palette.MAIN,
                                    negativeButtonColor: Colors.grey,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        }
      },
    );
  }
}
