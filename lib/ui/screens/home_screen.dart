// ignore_for_file: depend_on_referenced_packages

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    ooBloc.getAllUserEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  LU.of(context).my_events,
                  style: const TextStyle(
                    fontSize: 20,
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
                SizedBox(
                  height: 35,
                  width: 50,
                  child: IconButton(
                    onPressed: () {
                            ooBloc.getAllClubs();

                      _openJoinClubModal(context);
                    },
                    icon: const Icon(
                      Icons.class_,
                      color: Palette.MAIN,
                    ),
                  ),
                ),
                SizedBox(
                  height: 35,
                  width: 50,
                  child: IconButton(
                    onPressed: () {
                      _openCreateClubModal(context);
                    },
                    icon: const Icon(
                      Icons.class_,
                      color: Palette.MAIN,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200, // Set a fixed height for the container
            child: StreamBuilder<List<Event>>(
              stream: ooBloc.getAllEventsSubject,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final events = snapshot.data!;
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
                    hintText: 'dd/mm/yyyy',
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
                          // Add logic to save the new event
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
                          String dateString = dateController.text;
                          DateTime date =
                              DateFormat('dd/MM/yyyy').parse(dateString);

                          ooBloc.createEvent(
                              titleController.text,
                              descriptionController.text,
                              date,
                              locationController.text);

                          Navigator.pop(context); // Close the modal
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

void _openCreateClubModal(BuildContext context) {
  String clubName = '';
  String clubDescription = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Create a Club'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RoundedTextField(
              labelText: 'Club Name',
              onChanged: (value) {
                clubName = value!;
              },
            ),
            SizedBox(
              height: 20,
            ),
            RoundedTextField(
              labelText: 'Club Description',
              onChanged: (value) {
                clubDescription = value!;
              },
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
style: TextButton.styleFrom(
    foregroundColor: Colors.grey, // Sets the text color
  ),            onPressed: () {
                  // Close the dialog without creating the club
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
style: TextButton.styleFrom(
    foregroundColor: Palette.MAIN, // Sets the text color
  ),
                onPressed: () {
                  // Call the create club method from your Bloc and pass the clubName and clubDescription
                  ooBloc.createClub(
                    name: clubName,
                    description: clubDescription,
                  ); // Replace ooBloc with your actual Bloc instance

                  // Close the dialog
                  Navigator.pop(context);
                },
                child: Text('Create'),
              ),
            ],
          ),
          
        ],
      );
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

