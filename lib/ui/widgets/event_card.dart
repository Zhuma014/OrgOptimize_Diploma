// ignore: depend_on_referenced_packages
// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, duplicate_ignore, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/club/club_events.dart';
import 'package:urven/data/models/user/attendance.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/common_input_field.dart';
import 'package:urven/utils/common_dialog.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';

class EventCard extends StatefulWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
    bool _attending = false;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(SSC.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.event.title ?? 'No Title',
                    style: const TextStyle(
                      fontSize: SSC.p16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.event.description != null &&
                      widget.event.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: SSC.p8),
                      child: Text(
                        widget.event.description!,
                        style: const TextStyle(fontSize: SSC.p14),
                      ),
                    ),

                  if (widget.event.date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: SSC.p8),
                      child: Text(
                        DateFormat('dd MMM yyyy HH:mm').format(widget.event.date!),
                        style: const TextStyle(
                          fontSize: SSC.p12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  if (widget.event.location != null && widget.event.location!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: SSC.p8),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: SSC.p16, color: Colors.grey),
                          const SizedBox(width: SSC.p5),
                          Text(
                            widget.event.location!,
                            style: const TextStyle(
                                fontSize: SSC.p12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  if (widget.event.clubName != null && widget.event.clubName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: SSC.p8),
                      child: Text(
                        widget.event.clubName!,
                        style: const TextStyle(fontSize: SSC.p14),
                      ),
                    ),
                 if (widget.event.clubId != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: SSC.p16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _attending
                                  ? Colors.grey
                                  : Palette.MAIN,
                            ),
                            onPressed: _attending
                                ? null
                                : () {
                                    setState(() {
                                      _attending = true;
                                    });
                                    ooBloc.attendEvent(widget.event.id!);
                                                        Navigator.pop(context);

                                  },
                            child: const Text('I will come'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_attending
                                  ? Colors.grey 
                                  : Colors.red,
                            ),
                            onPressed: !_attending
                                ? null
                                : () {
                                    setState(() {
                                      _attending = false;
                                    });
                                    ooBloc.doNotAttendEvent(widget.event.id!);
                                                        Navigator.pop(context);

                                  },
                            child: const Text('I will not come'),
                          ),
                        ],
                      ),
                    ),
                  if (widget.event.userId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: SSC.p16),
                      child: Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Palette.MAIN,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it!'),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
      child: SizedBox(
        width: SSC.p200,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(SSC.p15), 
          ),
          child: Padding(
            padding: const EdgeInsets.all(SSC.p16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title ?? 'No Title',
                      style: const TextStyle(
                        fontSize: SSC.p16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.event.description != null &&
                        widget.event.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: SSC.p8),
                        child: Text(
                          widget.event.description!,
                          style: const TextStyle(fontSize: SSC.p14),
                        ),
                      ),
                    if (widget.event.date != null)
                      Padding(
                        padding: const EdgeInsets.only(top: SSC.p8),
                        child: Text(
                          DateFormat('dd MMM yyyy HH:mm').format(widget.event.date!),
                          style: const TextStyle(
                            fontSize: SSC.p12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    if (widget.event.location != null && widget.event.location!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: SSC.p8),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: SSC.p16, color: Colors.grey),
                            const SizedBox(width: SSC.p5),
                            Text(
                              widget.event.location!,
                              style: const TextStyle(
                                  fontSize: SSC.p12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    if (widget.event.clubName != null && widget.event.clubName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: SSC.p8),
                        child: Text(
                          widget.event.clubName!,
                          style: const TextStyle(fontSize: SSC.p14),
                        ),
                      ),
                  ],
                ),
               
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FutureBuilder<dynamic?>(
        future: widget.event.clubId != null
            ? ooBloc.getClubById(widget.event.clubId!)
            : Future.value(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Club? club = snapshot.data;
            bool isAdmin = widget.event.clubId == null || club?.adminId == ooBloc.userProfileSubject.value?.id;
            if (isAdmin) {
              return IconButton(
                icon: const Icon(Icons.edit, color: Palette.MAIN),
                onPressed: () {
                  _showEditEventModal(context);
                },
              );
            } else {
              // If the user is not an admin, return an empty container or another placeholder
              return Container(); // or SizedBox.shrink()
            }
          } else {
            // Return a placeholder widget while waiting for the future to complete
 return Container();          }
        },
      ),
        FutureBuilder<dynamic?>(
          future: widget.event.clubId != null
            ? ooBloc.getClubById(widget.event.clubId!)
            : Future.value(null),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Club? club = snapshot.data;
              bool isAdmin = widget.event.clubId == null || club?.adminId == ooBloc.userProfileSubject.value?.id;
              if (isAdmin) {
                return IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showCustomDialog(
                      context: context,
                      title: 'Delete Event',
                      description: 'Are you sure you want to delete this event?',
                      positiveText: 'Delete',
                      negativeText: 'Cancel',
                      onPositivePressed: () {
                        ooBloc.deleteEvent(widget.event.id!);
                      },
                      onNegativePressed: () {
                        // Optionally handle the cancel action here
                      },
                            positiveButtonColor: Colors.red, // Set the color for the positive button

                  // Set the color for the negative button
                    );
                  },
                );
              } else {
                // If the user is not an admin, return an empty container or another placeholder
                return Container(); // or SizedBox.shrink()
              }
            } else {
              // Return a placeholder widget while waiting for the future to complete
            return Container();
            }
          },
        ),
                
                              if (widget.event.clubId != null)
        FutureBuilder<dynamic?>(
          future: ooBloc.getClubById(widget.event.clubId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Club? club = snapshot.data;
              bool isAdmin = club != null && club.adminId == ooBloc.userProfileSubject.value?.id;
              if (isAdmin) {
                return IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return Container(
                              padding: const EdgeInsets.all(SSC.p16),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(SSC.p20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'List of attendees for ${widget.event.title}',
                                    style: const TextStyle(
                                      fontSize: SSC.p18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: SSC.p16),
                                  FutureBuilder<dynamic>(
                                    future: ooBloc.getAttendancesForEvent(widget.event.id!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else if (snapshot.hasData) {
                                        List<Attendance> attendances = snapshot.data!;
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: attendances.length,
                                          itemBuilder: (context, index) {
                                            Attendance attendance = attendances[index];
                                            return ListTile(
                                              title: Text(attendance.fullName),
                                            );
                                          },
                                        );
                                      } else {
                                        return const Text('No attendances found');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.visibility, color: Palette.MAIN),
                );
              } else {
                // If the user is not an admin, return an empty container or another placeholder
                return Container(); // or SizedBox.shrink()
              }
            } else {
              // Return a placeholder widget while waiting for the future to complete
              return Container();
            }
          },
        ),
                
                
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditEventModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    TextEditingController titleController =
        TextEditingController(text: widget.event.title);
    TextEditingController descriptionController =
        TextEditingController(text: widget.event.description);
    TextEditingController dateController = TextEditingController(
        text: DateFormat('dd MMM yyyy HH:mm').format(widget.event.date!));
    TextEditingController locationController =
        TextEditingController(text: widget.event.location);

    int? selectedClubId =
        widget.event.clubId ?? 0; 
    int? userProfileId =
        ooBloc.userProfileSubject.value?.id; 

    String? _validateDescription(String? value) {
      if (value == null || value.isEmpty) {
        return 'Description is required';
      }
      return null;
    }

    Future<void> _selectDateTime(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Palette
                    .MAIN,
                onPrimary: Colors.white, 
                surface: Palette.MAIN, 
                onSurface: Colors.black, 
              ),
              dialogBackgroundColor:
                  Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Palette
                      .MAIN, 
                  onPrimary: Colors.white, 
                  surface: Colors.white, 
                  onSurface: Colors.black, 
                ),
                dialogBackgroundColor:
                    Colors.white, 
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          final DateTime fullDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          dateController.text =
              DateFormat('dd MMM yyyy HH:mm').format(fullDateTime);
        }
      }
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SSC.p15),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (
          BuildContext context,
          StateSetter setState,
        ) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(SSC.p8),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SSC.p8, horizontal: SSC.p16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                LU.of(context).create_event,
                                style: const TextStyle(
                                  fontSize: SSC.p20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ])),
                    StreamBuilder<List<Club>>(
                      stream: ooBloc.getUserClubsSubject,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          List<Club> adminClubs = snapshot.data!
                              .where((club) => club.adminId == userProfileId)
                              .toList();
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: SSC.p15,
                              top: SSC.p5,
                              right: SSC.p15,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Select Club or My Own Event',
                                    style: TextStyle(
                                      color: Palette.MAIN.withOpacity(0.5),
                                      fontSize: SSC.p14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: SSC.p14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: SSC.p6),
                                DropdownButtonFormField<int>(
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white70,
                                    contentPadding: EdgeInsets.only(
                                      left: SSC.p10,
                                      top: SSC.p10,
                                      bottom: SSC.p10,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(SSC.p4),
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette.LIGHT_GREY_4,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(SSC.p4),
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette.LIGHT_GREY_4,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(SSC.p4),
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  value: selectedClubId,
                                  items: [
                                    const DropdownMenuItem(
                                      value: 0,
                                      child: Text('My Own Event'),
                                    ),
                                    ...adminClubs.map((club) {
                                      return DropdownMenuItem(
                                        value: club.id!,
                                        child: Text(club.name!),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedClubId = value;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? 'Please select a club or My Own Event'
                                      : null,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Text('No clubs available');
                        }
                      },
                    ),
                    const SizedBox(height: SSC.p8),
                    CommonInputField(
                      labelText: LU.of(context).title,
                      isRequired: true,
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      validator: _validateDescription,
                    ),
                    CommonInputField(
                      labelText: LU.of(context).description,
                      isRequired: true,
                      controller: descriptionController,
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      validator: _validateDescription,
                    ),
                    CommonInputField(
                      labelText: LU.of(context).date,
                      isRequired: true,
                      controller: dateController,
                      keyboardType: TextInputType.datetime,
                      hintText: 'Choose date and time',
                      readOnly: true,
                      onTap: () => _selectDateTime(context),
                      validator: _validateDescription,
                    ),
                    CommonInputField(
                      labelText: LU.of(context).location,
                      isRequired: true,
                      controller: locationController,
                      keyboardType: TextInputType.text,
                      validator: _validateDescription,
                    ),
                    const SizedBox(height: SSC.p20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Palette.BACKGROUND,
                              side: const BorderSide(color: Palette.MAIN)),
                          onPressed: () {
                            Navigator.pop(context); 
                          },
                          child: Text(
                            LU.of(context).action_cancel,
                            style: const TextStyle(color: Palette.MAIN),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Palette.MAIN),
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              String dateString = dateController.text;
                              DateTime date = DateFormat('dd MMM yyyy HH:mm')
                                  .parse(dateString);

                              if (selectedClubId == 0) {
                                ooBloc.updateEvent(
                                    widget.event.id!,
                                    titleController.text,
                                    descriptionController.text,
                                    date,
                                    locationController.text);

                              } 

                              
                              else {
                                ooBloc.updateEvent(
                                  widget.event.id!,
                                  titleController.text,
                                  descriptionController.text,
                                  date,
                                  locationController.text,
                                  clubId: selectedClubId!,
                                );
                              }
                              setState(() {});

                              Navigator.pop(context);

                            }
                          },
                          child: Text(
                            LU.of(context).save,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SSC.p20),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
