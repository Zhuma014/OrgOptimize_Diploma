// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/common_dialog.dart';

class ClubInfoModal extends StatefulWidget {
  final Club club;
  final Function(Club) onUpdate;

  const ClubInfoModal({super.key, required this.club, required this.onUpdate});

  @override
  _ClubInfoModalState createState() => _ClubInfoModalState();
}

class _ClubInfoModalState extends State<ClubInfoModal> {
  late Future<UserProfile?> _adminProfile;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _adminProfile = ooBloc.getUserProfileById(widget.club.adminId!);
    _nameController = TextEditingController(text: widget.club.name);
    _descriptionController = TextEditingController(text: widget.club.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<UserProfile?>(
            future: _adminProfile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error fetching admin profile: ${snapshot.error}'),
                );
              }
              if (snapshot.hasData) {
                final adminProfile = snapshot.data!;

                return Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.club.name!,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Palette.MAIN,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Text(
                              'ID: ',
                              style: TextStyle(
                                color: Palette.MAIN.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              '${widget.club.id}',
                              style: const TextStyle(
                                color: Palette.MAIN,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Text(
                              'Admin: ',
                              style: TextStyle(
                                color: Palette.MAIN.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              '${adminProfile.fullName}',
                              style: const TextStyle(
                                color: Palette.MAIN,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Text(
                              'Created At: ',
                              style: TextStyle(
                                color: Palette.MAIN.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              widget.club.createdAt!.toString().split(' ')[0],
                              style: const TextStyle(
                                color: Palette.MAIN,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          widget.club.description!,
                          style: TextStyle(
                            color: Palette.MAIN.withOpacity(0.7),
                          ),
                        ),
                        ],
                    ),
                    const SizedBox(width: 80,),
                  

                    if (ooBloc.userProfileSubject.value?.id == widget.club.adminId) ...[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                _openEditClubModal(
                                  context,
                                  widget.onUpdate,
                                );
                              },
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit',
                              color: Palette.MAIN,
                            ),
                            IconButton(
                              onPressed: () {
                                ooBloc.deleteClub(widget.club.id!);
                                widget.onUpdate(Club(id: widget.club.id, isDeleted: true));
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.delete),
                              tooltip: 'Delete',
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ] else
                      ElevatedButton(
    style:ElevatedButton.styleFrom(backgroundColor: Colors.red),
    onPressed: () {
      // Show the custom dialog before leaving the club
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
          // Do nothing, close the dialog
        },
        positiveButtonColor: Colors.red,
        negativeButtonColor: Colors.grey,
      );
    },
    child: const Text('Leave the club'),
  ),
                      ],
                );
                  
              }
              return const Text("Error");
            },
          ),
        ),
      ),
    );
  }



  void _openEditClubModal(BuildContext context, Function(Club) onUpdate) {
    bool isButtonEnabled = _nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Edit Club',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    onChanged: (value) {
                      setState(() {
                        isButtonEnabled = value.isNotEmpty && _descriptionController.text.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Club Name',
                      labelStyle: const TextStyle(
                        color: Palette.MAIN,
                        fontSize: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    onChanged: (value) {
                      setState(() {
                        isButtonEnabled = _nameController.text.isNotEmpty && value.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Club Description',
                      labelStyle: const TextStyle(
                        color: Palette.MAIN,
                        fontSize: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: isButtonEnabled
                          ? () async {
                              // Handle edit club logic
                              Club? updatedClub = await ooBloc.updateClub(
                                clubId: widget.club.id!,
                                name: _nameController.text,
                                description: _descriptionController.text,
                              );

                              if (updatedClub != null) {
                                setState(() {
        // Update the controllers with the new values
        _nameController.text = updatedClub.name!;
        _descriptionController.text = updatedClub.description!;
      });
                                onUpdate(updatedClub);
                              }

                              Navigator.pop(context);
                            }
                          : null, // Disable button if not all fields are filled
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Palette.MAIN, fontSize: 16),
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
