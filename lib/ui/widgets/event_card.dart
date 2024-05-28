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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    widget.event.title ?? 'No Title',
                    style: const TextStyle(
                      fontSize: SSC.p16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Description
                  if (widget.event.description != null &&
                      widget.event.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        widget.event.description!,
                        style: const TextStyle(fontSize: SSC.p14),
                      ),
                    ),

                  // Date and Time
                  if (widget.event.date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('dd MMM yyyy HH:mm').format(widget.event.date!),
                        style: const TextStyle(
                          fontSize: SSC.p12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  // Location
                  if (widget.event.location != null && widget.event.location!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            widget.event.location!,
                            style: const TextStyle(
                                fontSize: SSC.p12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  // Club Name
                  if (widget.event.clubName != null && widget.event.clubName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        widget.event.clubName!,
                        style: const TextStyle(fontSize: SSC.p14),
                      ),
                    ),
                 if (widget.event.clubId != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _attending
                                  ? Colors.grey // Disable the button if attending
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
                                  ? Colors.grey // Disable the button if not attending
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
                      padding: const EdgeInsets.only(top: 16.0),
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
        width: 200,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15.0), // Adjust the value as needed
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.event.title ?? 'No Title',
                      style: const TextStyle(
                        fontSize: SSC.p16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Description
                    if (widget.event.description != null &&
                        widget.event.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          widget.event.description!,
                          style: const TextStyle(fontSize: SSC.p14),
                        ),
                      ),
                    // Date and Time
                    if (widget.event.date != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('dd MMM yyyy HH:mm').format(widget.event.date!),
                          style: const TextStyle(
                            fontSize: SSC.p12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    // Location
                    if (widget.event.location != null && widget.event.location!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(
                              widget.event.location!,
                              style: const TextStyle(
                                  fontSize: SSC.p12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    // Club Name
                    if (widget.event.clubName != null && widget.event.clubName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          widget.event.clubName!,
                          style: const TextStyle(fontSize: SSC.p14),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  width: 150,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
  icon: const Icon(Icons.edit, color: Palette.MAIN),
  onPressed: () async {
    if (widget.event.clubId != null) {
      Club? club = await ooBloc.getClubById(widget.event.clubId!);
      if (club != null && club.adminId == ooBloc.userProfileSubject.value?.id) {
        _showEditEventModal(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not an admin'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      _showEditEventModal(context);
    }
  },
),
                IconButton(
  icon: const Icon(Icons.delete, color: Colors.red),
  onPressed: () async {
    if (widget.event.clubId == null) {
      // Event doesn't belong to any club, allow deletion
      ooBloc.deleteEvent(widget.event.id!);
    } else {
      Club? club = await ooBloc.getClubById(widget.event.clubId!);
      if (club != null && club.adminId == ooBloc.userProfileSubject.value?.id) {
        ooBloc.deleteEvent(widget.event.id!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not an admin'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  },
),

                        if(widget.event.clubId != null)
                   IconButton(
  onPressed: () async {
    Club? club = await ooBloc.getClubById(widget.event.clubId!);
                        if (
                            club != null &&
                                club.adminId ==
                                    ooBloc.userProfileSubject.value?.id) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'List of attendees for ${widget.event.title}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are not an admin'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  },
  icon: const Icon(Icons.visibility, color: Palette.MAIN),
),


                  ],
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
        widget.event.clubId ?? 0; // Initialize selectedClubId based on event's clubId
    int? userProfileId =
        ooBloc.userProfileSubject.value?.id; // Initialize userProfile

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
                    .MAIN, // Use Palette.Main for header background color
                onPrimary: Colors.white, // Header text color
                surface: Palette.MAIN, // Body background color (optional)
                onSurface: Colors.black, // Body text color
              ),
              dialogBackgroundColor:
                  Colors.white, // Background color of the dialog
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
                      .MAIN, // Use Palette.Main for header background color
                  onPrimary: Colors.white, // Header text color
                  surface: Colors.white, // Body background color (optional)
                  onSurface: Colors.black, // Body text color
                ),
                dialogBackgroundColor:
                    Colors.white, // Background color of the dialog
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
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                LU.of(context).create_event,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ])),
                    // Add Dropdown for selecting Club or My Own Event
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
                    const SizedBox(height: 8.0),
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
                      // Use onTap to show date and time picker
                    ),
                    CommonInputField(
                      labelText: LU.of(context).location,
                      isRequired: true,
                      controller: locationController,
                      keyboardType: TextInputType.text,
                      validator: _validateDescription,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Palette.BACKGROUND,
                              side: const BorderSide(color: Palette.MAIN)),
                          onPressed: () {
                            Navigator.pop(context); // Close the modal
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

                              // Close the modal
                            }
                          },
                          child: Text(
                            LU.of(context).save,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
