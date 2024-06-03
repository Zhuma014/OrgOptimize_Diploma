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
import 'package:urven/utils/screen_size_configs.dart';

class MyClubsScreen extends StatefulWidget {
  const MyClubsScreen({super.key});

  @override
  _MyClubsScreenState createState() => _MyClubsScreenState();
}

class _MyClubsScreenState extends State<MyClubsScreen> {
  List<Club> userClubs = [];
  List<JoinRequest> joinRequests = [];
  List<JoinRequest> pendingRequests = [];

  int selectedClubId = 0;
  StreamSubscription<List<Club>>? userClubsSubscription;
  StreamSubscription<List<JoinRequest>>? joinRequestsSubscription;

  bool isDialogOpen = false; 

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
        print('Failed to fetch user clubs: $error');
      },
    );
    ooBloc.getUserClubs();
    ooBloc.getUserProfile();
  }

  @override
  void dispose() {
    userClubsSubscription?.cancel();
    joinRequestsSubscription?.cancel(); 
    super.dispose();
  }

  Future<void> approveJoinRequest(int clubId, int requestId) async {
    try {
      await ooBloc.approveJoinRequest(clubId, requestId);
      setState(() {
        joinRequests.removeWhere((request) => request.id == requestId);
        pendingRequests.removeWhere((request) => request.id == requestId);
      });
    } catch (error) {
      print('Failed to approve join request: $error');
    }
  }

  Future<void> rejectJoinRequest(int clubId, int requestId) async {
    try {
      await ooBloc.rejectJoinRequest(clubId, requestId);
      setState(() {
        joinRequests.removeWhere((request) => request.id == requestId);
        pendingRequests.removeWhere((request) => request.id == requestId);
      });
    } catch (error) {
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
            padding: EdgeInsets.only(top: SSC.p10),
            child: Toolbar(
              isBackButtonVisible: true,
              title: "My Clubs",
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: SSC.p25),
            child: Row(
              children: [
                Text(
                  "* ",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: SSC.p16,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: SSC.p10),
                    child: Text(
                      "This page is for clubs that you are an admin or member of. If you are an admin, you can view membership requests by clicking on a club.",
                      style: TextStyle(
                        fontSize: SSC.p14,
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
                          padding: const EdgeInsets.all(SSC.p50),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                  'You are not a member of any club, please create your own club or be the member of'),
                              const SizedBox(height: SSC.p16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Palette.MAIN),
                                onPressed: () {
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
                                      isAdmin ? '' : 'You are Member',
                                      style:
                                          const TextStyle(color: Palette.MAIN),
                                    ),
                                    if (isAdmin) const SizedBox(width: SSC.p8),
                                    if (isAdmin)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Palette.MAIN,
                                          backgroundColor: Palette
                                              .BACKGROUND, 
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                SSC.p10), 
                                          ),
                                          elevation: SSC.p4, 
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: SSC.p20,
                                              vertical: SSC.p10), 
                                        ),
                                        onPressed: () async {
                                          if (club.adminId ==
                                              ooBloc.userProfileSubject.value
                                                  ?.id) {
                                            setState(() {
                                              selectedClubId = club.id!;
                                            });
                                            await ooBloc.getJoinRequests(
                                                selectedClubId);

                                            if (!isDialogOpen) {
                                              showUserProfileDialog();
                                            }
                                          }
                                        },
                                        child: const Text('Requests'),
                                      ),
                                    if (isAdmin)
                                      const SizedBox(
                                        width: SSC.p10,
                                      ),
                                    if (isAdmin)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor:
                                              Palette.MAIN, 
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                SSC.p10), 
                                          ),
                                          elevation: SSC.p4, 
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: SSC.p20,
                                              vertical: SSC.p10), 
                                        ),
                                        onPressed: () async {
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
                                        child: const Text('Members'),
                                      ),
                                  ],
                                ),
                              ),
                              onTap: () async {},
                            );
                          });
                    }
                  })),
        ],
      ),
    );
  }

  Future<void> showUserProfileDialog() async {
    if (isDialogOpen) {
      return;
    }

    isDialogOpen = true;

    joinRequests = ooBloc.joinRequestListSubject.value;
    pendingRequests =
        joinRequests.where((request) => request.status == 'pending').toList();

    int numRequests = pendingRequests.length;

    showDialog(
      context: context,
      barrierDismissible: false,
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
                      fontSize: SSC.p20,
                      color: Palette.MAIN,
                    ),
                  ),
                  Text(
                    '($numRequests)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SSC.p20,
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
                            padding: EdgeInsets.all(SSC.p16),
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
                                return StatefulBuilder(
                                    builder: (context, setState) {
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
                                                  IconButton(
                                                    icon:
                                                        const Icon(Icons.check),
                                                    color: Colors.green,
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
                                                  IconButton(
                                                    icon:
                                                        const Icon(Icons.close),
                                                    color: Colors.red,
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
                                });
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
                    setState(() {
                      isDialogOpen = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      isDialogOpen = false;
    });
  }
}
