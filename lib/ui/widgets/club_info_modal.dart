// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/common_dialog.dart';
import 'package:urven/utils/screen_size_configs.dart';
import 'package:urven/utils/lu.dart';

class ClubInfoModal extends StatefulWidget {
  final Club club;
  final Function(Club) onUpdate;

  const ClubInfoModal({super.key, required this.club, required this.onUpdate});

  @override
  _ClubInfoModalState createState() => _ClubInfoModalState();
}

class _ClubInfoModalState extends State<ClubInfoModal> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.club.name);
    _descriptionController = TextEditingController(text: widget.club.description);
    _fetchAdminProfile(); 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

 Future<void> _fetchAdminProfile() async {
    print('Fetching profile for adminId: ${widget.club.adminId}');
    try {
      await ooBloc.getUserProfileById(widget.club.adminId!);
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(SSC.p16),
          child: StreamBuilder<UserProfile?>(
            stream: ooBloc.userProfileByIdSubject.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error fetching admin profile: ${snapshot.error}'),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                final adminProfile = snapshot.data!;
                return _buildAdminProfileContent(adminProfile);
              }

              return Text(LU.of(context).admin_not_found);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAdminProfileContent(UserProfile adminProfile) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.club.name!,
                style: const TextStyle(
                  fontSize: SSC.p18,
                  fontWeight: FontWeight.bold,
                  color: Palette.MAIN,
                ),
              ),
              const SizedBox(height: SSC.p8),
              Row(
                children: [
                  Text(
                    '${LU.of(context).admin}:  ',
                    style: TextStyle(
                        color: Palette.DARK_BLUE.withOpacity(0.7),
                        fontWeight: FontWeight.w200),
                  ),
                  Flexible(
                    child: Text(
                      adminProfile.fullName!,
                      style: const TextStyle(
                        color: Palette.MAIN,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SSC.p8),
              Row(
                children: [
                  Text(
                    '${LU.of(context).created_at}:  ',
                    style: TextStyle(
                        color: Palette.DARK_BLUE.withOpacity(0.7),
                        fontWeight: FontWeight.w200),
                  ),
                  Flexible(
                    child: Text(
                      widget.club.createdAt!.toString().split(' ')[0],
                      style: const TextStyle(
                        color: Palette.MAIN,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SSC.p8),
              Flexible(
                child: Text(
                  widget.club.description!,
                  style: TextStyle(
                    color: Palette.MAIN.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (ooBloc.userProfileSubject.value?.id == widget.club.adminId) ...[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      onPressed: () {
                        _openEditClubModal(
                          context,
                          widget.onUpdate,
                        );
                      },
                      icon: const Icon(Icons.edit),
                      padding: EdgeInsets.zero,
                      tooltip: 'Edit',
                      color: Palette.MAIN,
                    ),
                   IconButton(
                        onPressed: () {
                        showCustomDialog(
                          context: context,
                          title: 'Delete Club',
                          description: 'Are you sure you want to delete this club?',
                          positiveText: 'Delete',
                          negativeText: 'Cancel',
                          onPositivePressed: () {
                            ooBloc.deleteClub(widget.club.id!);
                            widget.onUpdate(Club(id: widget.club.id, isDeleted: true));

                                                                Navigator.pop(context);

                          },
                          onNegativePressed: () {
                            // Optionally handle the cancel action here
                          },
                          positiveButtonColor: Colors.red, // Set the color for the positive button
                        );
                        },
                        icon: const Icon(Icons.delete),
                        padding: EdgeInsets.zero,
                        tooltip: 'Delete',
                        color: Colors.red,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ] else
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              showCustomDialog(
                context: context,
                title: 'Leave the Club',
                description: 'Are you sure you want to leave the club?',
                positiveText: 'Yes, leave',
                negativeText: 'Cancel',
                onPositivePressed: () {
                  ooBloc.leaveClub(widget.club.id!);
                  widget.onUpdate(Club(id: widget.club.id, isDeleted: true));
    
                                    Navigator.pop(context);

                },
                onNegativePressed: () {
                },
               
              );
            },
            child: Text(LU.of(context).leave_the_club),
          ),
      ],
    );
  }


  void _openEditClubModal(BuildContext context, Function(Club) onUpdate) {
    bool isButtonEnabled = _nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                LU.of(context).edit_club,
                style: const TextStyle(fontSize: SSC.p20, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    onChanged: (value) {
                      setState(() {
                        isButtonEnabled = value.isNotEmpty &&
                            _descriptionController.text.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Club Name',
                      labelStyle: const TextStyle(
                        color: Palette.MAIN,
                        fontSize: SSC.p16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SSC.p10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SSC.p10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: SSC.p10, horizontal: SSC.p16),
                    ),
                  ),
                  const SizedBox(height: SSC.p10),
                  TextField(
                    controller: _descriptionController,
                    onChanged: (value) {
                      setState(() {
                        isButtonEnabled =
                            _nameController.text.isNotEmpty && value.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Club Description',
                      labelStyle: const TextStyle(
                        color: Palette.MAIN,
                        fontSize: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SSC.p10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SSC.p10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: SSC.p10, horizontal: SSC.p16),
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        LU.of(context).action_cancel,
                        style: const TextStyle(color: Colors.grey, fontSize: SSC.p16),
                      ),
                    ),
                    TextButton(
                      onPressed: isButtonEnabled
                          ? () async {
                              Club? updatedClub = await ooBloc.updateClub(
                                clubId: widget.club.id!,
                                name: _nameController.text,
                                description: _descriptionController.text,
                              );

                              if (updatedClub != null) {
                                setState(() {
                                  _nameController.text = updatedClub.name!;
                                  _descriptionController.text =
                                      updatedClub.description!;
                                });
                                onUpdate(updatedClub);
                              }

                              Navigator.pop(context);
                            }
                          : null,
                      child: Text(
                        LU.of(context).edit,
                        style: const TextStyle(color: Palette.MAIN, fontSize: SSC.p16),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
