// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/user/join_request.dart';

import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/ui/screens/navigation.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/club_members_dialog.dart';
import 'package:urven/ui/widgets/toolbar.dart';

class MyClubsScreen extends StatefulWidget {
  const MyClubsScreen({super.key});

  @override
  _MyClubsScreenState createState() => _MyClubsScreenState();
}

class _MyClubsScreenState extends State<MyClubsScreen> {
  List<Club> userClubs = [];
  List<JoinRequest> joinRequests = [];

  int selectedClubId = 0;
  StreamSubscription<List<Club>>? userClubsSubscription;
  StreamSubscription<List<JoinRequest>>? joinRequestsSubscription;

  bool isDialogOpen = false; // Track the dialog state

  @override
  void initState() {
    super.initState();
    userClubsSubscription = ooBloc.getUserClubsSubject.listen(
      (List<Club> clubs) {
        setState(() {
          userClubs = clubs;
        });
      },
      onError: (error) {
        // Handle any error that occurs during the stream
        print('Failed to fetch user clubs: $error');
      },
    );
    ooBloc.getUserClubs();
  }

  @override
  void dispose() {
    userClubsSubscription?.cancel();
    joinRequestsSubscription?.cancel(); // Cancel the join requests subscription
    super.dispose();
  }

  Future<void> getJoinRequests(int clubId) async {
    try {
      // Listen for join requests
      ooBloc.getJoinRequests(clubId);

      joinRequestsSubscription = ooBloc.joinRequestListSubject.listen(
        (List<JoinRequest> requests) {
          setState(() {
            joinRequests = requests;
          });

          // Show dialog only if there are pending join requests
          if (joinRequests.isNotEmpty && !isDialogOpen) {
            showUserProfileDialog();
          }
        },
        onError: (error) {
          // Handle error
          print('Failed to fetch join requests: $error');
        },
      );
    } catch (error) {
      // Handle error
      print('Failed to fetch join requests: $error');
    }
  }

  Future<void> approveJoinRequest(int clubId, int requestId) async {
    try {
      await ooBloc.approveJoinRequest(clubId, requestId);
    } catch (error) {
      // Handle error
      print('Failed to approve join request: $error');
    }
  }

  Future<void> rejectJoinRequest(int clubId, int requestId) async {
    try {
      await ooBloc.rejectJoinRequest(clubId, requestId);
    } catch (error) {
      // Handle error
      print('Failed to reject join request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Toolbar(
              isBackButtonVisible: true,
              title: "My Clubs",
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              children: [
                Text(
                  "* ",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "This page is for clubs that you are an admin or member of. If you are an admin, you can view membership requests by clicking on a club.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: StreamBuilder<List<Club>>(
                  stream: ooBloc.getUserClubsSubject,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(50),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                  'You are not a member of any club, please create your own club or be the member of'),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Palette.MAIN),
                                onPressed: () {
                                  // Navigate to the allClubsScreen
                                  Navigator.pushNamed(
                                      context, Navigation.ALLCLUBS);
                                },
                                child: const Text('Join Clubs'),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      final userClubs = snapshot.data!;
                      return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: userClubs.length,
                          itemBuilder: (BuildContext context, int index) {
                            final club = userClubs[index];
                            final isAdmin = club.adminId ==
                                ooBloc.userProfileSubject.value?.id;
                            return ListTile(
                              title: Text(club.name ?? ''),
                              subtitle: Text(club.description ?? ''),
                              trailing: SizedBox(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isAdmin
                                          ? ''
                                          : 'You are Member',style: TextStyle(color: Palette.MAIN),
                                    ),
                                    if (isAdmin)
                                      SizedBox(width: 8),
                                       if (isAdmin)
                                      ElevatedButton(
                                       style: ElevatedButton.styleFrom(
    primary: Palette.BACKGROUND, // background color
    onPrimary: Palette.MAIN, // foreground color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // rounded corners
    ),
    elevation: 4, // shadow
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // button padding
  ),
                                        onPressed: () async {
                                if (club.adminId ==
                                    ooBloc.userProfileSubject.value?.id) {
                                  setState(() {
                                    selectedClubId = club.id!;
                                    joinRequests
                                        .clear(); // Clear the previous requests
                                  });
                                  await getJoinRequests(club.id!);

                                  // Show dialog only if there are pending join requests
                                  if (!isDialogOpen && joinRequests.isNotEmpty ) {
                                    showUserProfileDialog();
                                  }
                                  else{
                                    ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No requests yet")),
        );
                                  }
                                }
                              },
                                        child: Text('Requests'),
                                      ),
                                      if (isAdmin)
                                      SizedBox(width: 10,),
                                    if (isAdmin)
                                      ElevatedButton(
    style: ElevatedButton.styleFrom(
    primary: Palette.MAIN, // background color
    onPrimary: Colors.white, // foreground color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // rounded corners
    ),
    elevation: 4, // shadow
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // button padding
  ),                                        onPressed: () async {
                                          await ooBloc.getClubMembers(club.id!);
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                ClubMembersDialog(
                                              clubId: club.id!,
                                              clubName: club.name ?? 'Club',
                                            ),
                                          );
                                        },
                                        child: Text('Members'),
                                      ),

                                     
                                  ],
                                ),
                              ),
                              onTap: () async {
                               
                              },
                            );
                          });
                    }
                  })),
        ],
      ),
    );
  }

  Future<void> showUserProfileDialog() async {
    isDialogOpen = true; // Set the dialog state to open

    // Filter the join requests to show only pending requests
    List<JoinRequest> pendingRequests =
        joinRequests.where((request) => request.status == 'pending').toList();

    // Determine the number of pending requests
    int numRequests = pendingRequests.length;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing on outside tap
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Join Requests',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Palette.MAIN,
                    ),
                  ),
                  Text(
                    '($numRequests)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Palette.MAIN,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: numRequests == 0
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'There are no requests',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ]
                      : pendingRequests.map((request) {
                          return FutureBuilder<UserProfile?>(
                            future: ooBloc.getUserProfileById(request.userId!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const ListTile(
                                  title: Text('Loading user info...'),
                                );
                              } else if (snapshot.hasError) {
                                return const ListTile(
                                  title: Text('Error loading user info'),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data != null) {
                                UserProfile userProfile = snapshot.data!;
                                return ListTile(
                                  title: Text(
                                      'User: ${userProfile.fullName ?? 'Unknown'}'),
                                  subtitle: Text('Request ID: ${request.id}'),
                                  trailing: request.status == 'approved'
                                      ? const Text('Approved')
                                      : request.status == 'rejected'
                                          ? const Text('Rejected')
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton(
                                                  child: const Text(
                                                    'Approve',
                                                    style: TextStyle(
                                                        color: Palette.MAIN),
                                                  ),
                                                  onPressed: () async {
                                                    await approveJoinRequest(
                                                        selectedClubId,
                                                        request.id!);
                                                    setState(() {
                                                      request.status =
                                                          'approved';
                                                    });
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text(
                                                    'Reject',
                                                    style: TextStyle(
                                                        color: Palette.MAIN),
                                                  ),
                                                  onPressed: () async {
                                                    await rejectJoinRequest(
                                                        selectedClubId,
                                                        request.id!);
                                                    setState(() {
                                                      request.status =
                                                          'rejected';
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                );
                              } else {
                                return const ListTile(
                                  title: Text('User not found'),
                                );
                              }
                            },
                          );
                        }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    isDialogOpen = false;
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
