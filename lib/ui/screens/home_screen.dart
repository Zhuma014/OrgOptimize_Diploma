// ignore_for_file: depend_on_referenced_packages

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/club/club_events.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/common_input_field.dart';
import 'package:urven/ui/widgets/event_card.dart';
import 'package:urven/ui/widgets/text_field.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/common_dialog.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin
    implements TickerProvider {
  late TabController _tabController;
  late EventType selectedEventType;
  bool isSortedByDate = false;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    selectedEventType = EventType.both;
    ooBloc.getAllUserEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

    void sortEventsByDate(List<Event> events) {
    events.sort((a, b) => a.date!.compareTo(b.date!));
  }

    List<Event> filterEventsByType(List<Event> events) {
    if (selectedEventType == EventType.userOwned) {
      return events.where((event) => event.clubId == null).toList();
    } else if (selectedEventType == EventType.club) {
      return events.where((event) => event.clubId != null).toList();
    } else {
      return events;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Toolbar(
              isBackButtonVisible: false,
              title: LU.of(context).home,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                Text(
                  "Upcoming Events",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 35,
                  width: 50,
                  child: IconButton(
                    onPressed: () {
                      _showAddEventModal(context);
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Palette.MAIN,
                    ),
                  ),
                ),
                DropdownButton<EventType>(
                  value: selectedEventType,
                  onChanged: (value) {
                    setState(() {
                      selectedEventType = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: EventType.userOwned,
                      child: Text('User Owned'),
                    ),
                    DropdownMenuItem(
                      value: EventType.club,
                      child: Text('Club'),
                    ),
                    DropdownMenuItem(
                      value: EventType.both,
                      child: Text('Both'),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSortedByDate = !isSortedByDate;
                    });
                  },
                  child: Text(
                    isSortedByDate ? 'Sorted' : 'Sort',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                Spacer(),
                // SizedBox(
                //   height: 35,
                //   width: 50,
                //   child: IconButton(
                //     onPressed: () {
                //       ooBloc.getAllClubs();
            
                //       _openJoinClubModal(context);
                //     },
                //     icon: const Icon(
                //       Icons.class_,
                //       color: Palette.MAIN,
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 35,
                //   width: 50,
                //   child: IconButton(
                //     onPressed: () {
                //       _openCreateClubModal(context);
                //     },
                //     icon: const Icon(
                //       Icons.class_,
                //       color: Palette.MAIN,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          SizedBox(
  height: 200, // Set a fixed height for the container
  child: StreamBuilder<List<Event>>(
    stream: ooBloc.getAllEventsSubject,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        List<Event> events = snapshot.data!;
        if (isSortedByDate) {
          sortEventsByDate(events);
        }
        events = filterEventsByType(events);
        if (events.isEmpty) {
          return const Center(
            child: Text("You don't have events"),
          );
        } else {
          return ListView(
            scrollDirection: Axis.horizontal,
            children: events.map((event) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: EventCard(event: event),
              );
            }).toList(),
          );
        }
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      return const Center(child: CircularProgressIndicator());
    },
  ),
),
        ],
      ),
    );
  }
}

void _showAddEventModal(BuildContext context) {
  final formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  int? selectedClubId; // Variable to hold the selected club ID

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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
                    stream: ooBloc.getUserClubsSubject.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        List<Club> adminClubs = snapshot.data!;
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
                                  children: [
                                    const TextSpan(
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
                                
                                decoration: InputDecoration(
                                  
                                  
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
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text('My Own Event'),
                                  ),
                                  ...adminClubs.map((club) {
                                    return DropdownMenuItem(
                                      value: club.id,
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
                        return Text('No clubs available');
                      }
                    },
                  ),
                  const SizedBox(height: 8.0),
                  CommonInputField(
                    labelText: LU.of(context).title,
                    isRequired: true,
                    controller: titleController,
                    keyboardType: TextInputType.text,
                  ),
                  CommonInputField(
                    labelText: LU.of(context).description,
                    isRequired: true,
                    controller: descriptionController,
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                  ),
                  CommonInputField(
                    labelText: LU.of(context).date,
                    isRequired: true,
                    controller: dateController,
                    keyboardType: TextInputType.datetime,
                    hintText: 'Choose date and time',
                    readOnly: true,
                    onTap: () => _selectDateTime(context), // Use onTap to show date and time picker
                  ),
                  CommonInputField(
                    labelText: LU.of(context).location,
                    isRequired: true,
                    controller: locationController,
                    keyboardType: TextInputType.text,
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
                            DateTime date = DateFormat('dd MMM yyyy HH:mm').parse(dateString);

                            if (selectedClubId == 0) {
                              ooBloc.createEvent(
                                  titleController.text,
                                  descriptionController.text,
                                  date,
                                  locationController.text);
                            } else {
                              ooBloc.createEvent(
                                  titleController.text,
                                  descriptionController.text,
                                  date,
                                  locationController.text,

                                  clubId: selectedClubId!,
);
                            }

                            Navigator.pop(context); // Close the modal
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


void _openJoinClubModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Join a Club'),
        content: Container(
          width: double.maxFinite,
          height: 200,
          child: StreamBuilder<List<Club>>(
            stream: ooBloc.getAllClubsSubject,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final clubs = snapshot.data;
                if (clubs != null && clubs.isNotEmpty) {
                  return ListView(
                    shrinkWrap: true,
                    children: clubs.map((club) {
                      return ListTile(
                        title: Text(club.name ?? ''),
                        subtitle: Text(club.description ?? ''),
                        onTap: () {
                          // Logic to handle selecting a club
                          Navigator.pop(context); // Close the dialog
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return Text('No clubs available.');
                }
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Logic to handle joining the selected club
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Join'),
          ),
        ],
      );
    },
  );
}


enum EventType {
  userOwned,
  club,
  both,
}
