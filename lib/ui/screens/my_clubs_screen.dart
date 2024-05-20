import 'dart:async';

import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/user/join_request.dart';

import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/toolbar.dart';

class MyClubsScreen extends StatefulWidget {
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
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Toolbar(
            isBackButtonVisible: true,
            title: "My Clubs",
          ),
        ),
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
          child: ListView.builder(
                        padding: EdgeInsets.zero, // Set padding to zero

            itemCount: userClubs.length,
            itemBuilder: (BuildContext context, int index) {
              final club = userClubs[index];
              return ListTile(
                title: Text(club.name ?? ''),
                subtitle: Text(club.description ?? ''),
                trailing: Text(
                  club.adminId == ooBloc.userProfileSubject.value?.id
                      ? 'Admin'
                      : 'Member',
                ),
                onTap: () async {
                  if (club.adminId ==
                      ooBloc.userProfileSubject.value?.id) {
                    final clubId = club.id!;
                    await getJoinRequests(clubId);
                    setState(() {
                      selectedClubId = clubId;
                    });

                    // Show dialog only if there are pending join requests
                    if (joinRequests.isNotEmpty && !isDialogOpen) {
                      showUserProfileDialog();
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

Future<void> showUserProfileDialog() async {
  isDialogOpen = true; // Set the dialog state to open

  // Filter the join requests to show only pending requests
  List<JoinRequest> pendingRequests = joinRequests.where((request) => request.status == 'pending').toList();

  // Determine the number of pending requests
  int numRequests = pendingRequests.length;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Join Requests',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Palette.MAIN, // Use Palette.MAIN as the text color for the title
              ),
            ),
            Text(
              '($numRequests)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Palette.MAIN, // Use Palette.MAIN as the text color for the title
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
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
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            title: Text('Loading user info...'),
                          );
                        } else if (snapshot.hasError) {
                          return ListTile(
                            title: Text('Error loading user info'),
                          );
                        } else if (snapshot.hasData && snapshot.data != null) {
                          UserProfile userProfile = snapshot.data!;
                          return ListTile(
                            title: Text('User: ${userProfile.fullName ?? 'Unknown'}'),
                            subtitle: Text('Request ID: ${request.id}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  child: Text(
                                    'Approve',
                                    style: TextStyle(color: Palette.MAIN), // Use Palette.MAIN as the text color for the button
                                  ),
                                  onPressed: () {
                                    approveJoinRequest(selectedClubId, request.id!);
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    'Reject',
                                    style: TextStyle(color: Palette.MAIN), // Use Palette.MAIN as the text color for the button
                                  ),
                                  onPressed: () {
                                    rejectJoinRequest(selectedClubId, request.id!);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          return ListTile(
                            title: Text('User not found'),
                          );
                        }
                      },
                    );
                  }).toList(),
          ),
        ),
      );
    },
  ).then((_) {
    isDialogOpen = false; // Reset the dialog state when closed
  });
}





}
