// ignore_for_file: depend_on_referenced_packages, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/club/club_events.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/common_input_field.dart';
import 'package:urven/ui/widgets/event_card.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';
 
import 'package:table_calendar/table_calendar.dart';
import 'package:rxdart/rxdart.dart';


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
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late UserProfile userProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    selectedEventType = EventType.both;
    ooBloc.getUserProfile();
    ooBloc.getAllUserEvents();
    ooBloc.getClubEvents();
    ooBloc.getOwnEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void sortEventsByDate(List<Event> events) {
    events.sort((a, b) => a.date!.compareTo(b.date!));
  }

  List<Event> getEventsForDay(DateTime day, List<Event> events) {
    return events.where((event) => isSameDay(event.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: SSC.p10),
            child: Toolbar(
              isBackButtonVisible: false,
              title: LU.of(context).home,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: SSC.p8, horizontal: SSC.p16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                      child: Text(LU.of(context).my, style: TextStyle(fontSize: SSC.p16)),
                    ),
                    DropdownMenuItem(
                      value: EventType.club,
                      child: Text(LU.of(context).clubs, style: TextStyle(fontSize: SSC.p16)),
                    ),
                    DropdownMenuItem(
                      value: EventType.both,
                      child: Text(LU.of(context).all, style: TextStyle(fontSize: SSC.p16)),
                    ),
                  ],
                ),
                Text(
                  LU.of(context).upcoming_events,
                  style: TextStyle(
                    fontSize: SSC.p16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Palette.MAIN,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Palette.MAIN.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Palette.MAIN),
              selectedTextStyle: const TextStyle(color: Colors.white),
              todayTextStyle: const TextStyle(color: Colors.white),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Palette.MAIN),
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(color: Palette.MAIN, fontSize: SSC.p16),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Palette.MAIN,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Palette.MAIN,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: selectedEventType == EventType.userOwned
                  ? ooBloc.getUserOwnedEventsSubject.stream
                  : selectedEventType == EventType.club
                      ? ooBloc.getClubEventsSubject.stream
                      : Rx.combineLatest2(
                          ooBloc.getUserOwnedEventsSubject.stream,
                          ooBloc.getClubEventsSubject.stream,
                          (List<Event> userEvents, List<Event> clubEvents) =>
                              userEvents + clubEvents,
                        ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Event> events = snapshot.data!;
                  if (isSortedByDate) {
                    sortEventsByDate(events);
                  } else {
                    events.sort((a, b) => a.date!.compareTo(b.date!));
                  }
                  List<Event> selectedDayEvents =
                      getEventsForDay(_selectedDay, events);
                  if (selectedDayEvents.isEmpty) {
                    return Center(
                      child: Text(LU.of(context).you_dont_have_events),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: selectedDayEvents.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: EventCard(event: selectedDayEvents[index]),
                        );
                      },
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Center(child: Text(LU.of(context).you_dont_have_events));
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventModal(context);
        },
        backgroundColor: Palette.MAIN,
        child: const Icon(Icons.add, color: Colors.white),
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

  int? selectedClubId;
  int? userProfileId =
      ooBloc.userProfileSubject.value?.id; 

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'The field is required';
    }
    return null;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate:  DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary:
                  Palette.MAIN, 
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                                  text: LU.of(context).club_or_my_event,
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
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text(LU.of(context).my_own_event),
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
                        return Text(LU.of(context).no_clubs_available);
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

enum EventType {
  userOwned,
  club,
  both,
}
