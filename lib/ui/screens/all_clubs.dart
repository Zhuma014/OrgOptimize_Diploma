import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/base/api_result.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/user/join_request.dart';
import 'package:urven/l10n/provider.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({Key? key}) : super(key: key);

  @override
  _ClubsScreenState createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  List<Club> userClubs = [];
  List<Club> allClubs = [];
  Set<int> pendingRequests = {};
  StreamSubscription<List<Club>>? userClubsSubscription;
  StreamSubscription<List<Club>>? allClubsSubscription;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
    fetchUserClubs();
    fetchAllClubs();
  }

  @override
  void dispose() {
    userClubsSubscription?.cancel();
    allClubsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPendingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingRequestsList = prefs.getStringList('pendingRequests') ?? [];
    setState(() {
      pendingRequests = pendingRequestsList.map(int.parse).toSet();
    });
  }

  Future<void> _savePendingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingRequestsList =
        pendingRequests.map((id) => id.toString()).toList();
    await prefs.setStringList('pendingRequests', pendingRequestsList);
  }

  void fetchUserClubs() {
    userClubsSubscription = ooBloc.getUserClubsSubject.listen((clubs) {
      if (mounted) {
        setState(() {
          userClubs = clubs;
        });
      }
    });
    ooBloc.getUserClubs();
  }

  void fetchAllClubs() {
    allClubsSubscription = ooBloc.getAllClubsSubject.listen((clubs) {
      if (mounted) {
        setState(() {
          allClubs = clubs;
        });
      }
    });
    ooBloc.getAllClubs();
  }

  bool isUserMemberOfClub(int clubId) {
    return userClubs.any((userClub) => userClub.id == clubId);
  }

  bool isRequestPending(int clubId) {
    return pendingRequests.contains(clubId);
  }

  void _openJoinClubModal(BuildContext context, int clubId) async {
    final isUserClubMember = isUserMemberOfClub(clubId);
    final isPending = isRequestPending(clubId);

    if (!isUserClubMember && !isPending) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Join a Club',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: Text(
              'Do you really want to join this club?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleJoinClub(clubId);
                },
                child: Text(
                  'Join',
                  style: TextStyle(
                    color: Palette.MAIN,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _handleJoinClub(int clubId) {
    late StreamSubscription subscription;

    subscription = ooBloc.joinRequestSubject.listen((response) {
      print(response);

      if (response.isValid) {
        setState(() {
          pendingRequests.add(clubId);
        });
        _savePendingRequests(); // Save the pending requests
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Your join request is pending."),
          ),
        );
      } else if (response.message == "User is already a member of the club") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You are already a member of the club."),
          ),
        );
      } else if (response.message == "Join request already exists") {
        setState(() {
          pendingRequests.add(clubId); // Ensure pendingRequests is updated
        });
        _savePendingRequests(); // Save the pending requests
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Your join request already exists."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message!),
          ),
        );
      }

      // Cancel the subscription after handling the response
      subscription.cancel();
    });

    ooBloc.joinClub(clubId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Toolbar(
                  isBackButtonVisible: true,
                  title: "Clubs",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Search',
                            labelStyle: TextStyle(
                              color: Palette.MAIN,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Palette.MAIN,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Palette.MAIN,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(
                              Icons.search,
                              color: Palette.MAIN,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openCreateClubModal(context),
                        icon: Icon(
                          Icons.add,
                          color: Palette.MAIN,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: StreamBuilder<List<Club>>(
                stream: ooBloc.getAllClubsSubject,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final clubs = snapshot.data!;
                    if (clubs.isEmpty) {
                      return Center(
                        child: Text('No clubs available.'),
                      );
                    } else {
                      return SingleChildScrollView(
                        child: Column(
                          children: clubs.map((club) {
                            final isUserClubMember =
                                isUserMemberOfClub(club.id!);
                            final isPending = isRequestPending(club.id!);
                            final isClubCreatedByUser = club.adminId ==
                                ooBloc.userProfileSubject.value
                                    ?.id; // Check if the club is created by the current user

                            return ListTile(
                              title: Text(
                                club.name!,
                                style: TextStyle(
                                  color: Palette.MAIN,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                club.description!,
                                style: TextStyle(
                                  color: Palette.DARK_BLUE,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: isClubCreatedByUser
                                  ? Text(
                                      'Member',
                                      style: TextStyle(color: Colors.green),
                                    )
                                  : isUserClubMember
                                      ? Text(
                                          'Member',
                                          style: TextStyle(color: Colors.green),
                                        )
                                      : isPending
                                          ? Text(
                                              'Requested',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            )
                                          : TextButton(
                                              onPressed: () {
                                                _openJoinClubModal(
                                                    context, club.id!);
                                              },
                                              child: Text('Join'),
                                            ),
                              onTap: isUserClubMember || isPending
                                  ? null
                                  : () {
                                      _openJoinClubModal(context, club.id!);
                                    },
                            );
                          }).toList(),
                        ),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: Palette.MAIN,
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Palette.MAIN,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

void _openCreateClubModal(BuildContext context) {
  String clubName = '';
  String clubDescription = '';
  bool isButtonEnabled = false; // Track button enable state

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Create a Club',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    clubName = value;
                    setState(() {
                      isButtonEnabled =
                          clubName.isNotEmpty && clubDescription.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Club Name',
                    labelStyle: TextStyle(
                      color: Palette.MAIN,
                      fontSize: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Palette.MAIN),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Palette.MAIN),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    clubDescription = value;
                    setState(() {
                      isButtonEnabled =
                          clubName.isNotEmpty && clubDescription.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Club Description',
                    labelStyle: TextStyle(
                      color: Palette.MAIN,
                      fontSize: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Palette.MAIN),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Palette.MAIN),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                      'Cancel',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: isButtonEnabled
                        ? () {
                            // Handle create club logic
                            // Replace ooBloc with your actual Bloc instance
                            ooBloc.createClub(
                              name: clubName,
                              description: clubDescription,
                            );

                            Navigator.pop(context);
                          }
                        : null, // Disable button if not all fields are filled
                    child: Text(
                      'Create',
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
