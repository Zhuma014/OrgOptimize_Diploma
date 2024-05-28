// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/toolbar.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({Key? key}) : super(key: key);

  @override
  _ClubsScreenState createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  String? searchText;
  List<Club> userClubs = [];
  Set<int> pendingRequests = {};
  TextEditingController searchController = TextEditingController();

  

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
    ooBloc.getAllClubs();
    ooBloc.getUserClubs(); // Add this line to fetch user clubs
    searchController.addListener(_filterClubs);
   ooBloc.getUserClubsSubject.stream.listen((clubs) {
    if (mounted) { // Check if the widget is mounted before calling setState
      setState(() {
        userClubs = clubs;
      });
    }
  });
  }

  @override
  void dispose() {

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

  void _filterClubs() {
    setState(() {
      searchText = searchController.text.toLowerCase();
    });
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
            title: const Text(
              'Join a Club',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: const Text(
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
                child: const Text(
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
                child: const Text(
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

      if (response.isValid) {
        setState(() {
          pendingRequests.add(clubId);
        });
        _savePendingRequests(); // Save the pending requests
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your join request is pending."),
          ),
        );
      } 
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your join request already exists."),
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
              const Padding(
                padding: EdgeInsets.only(top: 10),
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
                          controller: searchController,
                          decoration: InputDecoration(
                            labelText: 'Search',
                            labelStyle: const TextStyle(
                              color: Palette.MAIN,
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Palette.MAIN,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Palette.MAIN,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Palette.MAIN,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openCreateClubModal(context),
                        icon: const Icon(
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
        

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final clubs = snapshot.data!;
          List<Club> filteredClubs = clubs.where((club) {
            return club.name!
                .toLowerCase()
.contains(searchText?.toLowerCase() ?? '');
          }).toList();

          // Sort clubs: admin, member, other
          filteredClubs.sort((a, b) {
            final isAdminA =
                a.adminId == ooBloc.userProfileSubject.value?.id;
            final isMemberA = isUserMemberOfClub(a.id!);
            final isAdminB =
                b.adminId == ooBloc.userProfileSubject.value?.id;
            final isMemberB = isUserMemberOfClub(b.id!);

            if (isAdminA && !isAdminB) {
              return -1;
            } else if (!isAdminA && isAdminB) {
              return 1;
            } else {
              if (isMemberA && !isMemberB) {
                return -1;
              } else if (!isMemberA && isMemberB) {
                return 1;
              } else {
                return a.name!
                    .toLowerCase()
                    .compareTo(b.name!.toLowerCase());
              }
            }
          });
           if (snapshot.data!.isEmpty){
            return Center(
            child: Text(
              'No clubs available',
              style: TextStyle(
                color: Palette.MAIN,
              ),
            ),
          );
           }
          if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(
                color: Palette.MAIN,
              ),
            ),
          );
         }

          if (filteredClubs.isEmpty) {
            return Center(
              child: Text('No clubs available'),
            );
          } else {
            return ListView.builder(
              itemCount: filteredClubs.length,
              itemBuilder: (context, index) {
                final club = filteredClubs[index];
                final isUserClubMember =
                    isUserMemberOfClub(club.id!);
                final isPending = isRequestPending(club.id!);
                final isClubCreatedByUser = club.adminId ==
                    ooBloc.userProfileSubject.value?.id;

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
                          'Admin',
                          style: TextStyle(color: Colors.red),
                        )
                      : isUserClubMember
                          ? Text(
                              'Member',
                              style: TextStyle(color: Colors.green),
                            )
                          : isPending
                              ? Text(
                                  'Requested',
                                  style: TextStyle(color: Colors.grey),
                                )
                              : TextButton(
                                  onPressed: () {
                                    _openJoinClubModal(
                                        context, club.id!);
                                  },
                                  child: Text('Join'),
                                ),
                  onTap: isUserClubMember || isPending || isClubCreatedByUser
                      ? null
                      : () {
                          _openJoinClubModal(context, club.id!);
                        },
                );
              },
            );
          }
         }

        // This should never be reached, but just in case
        else
        return Center(
          child: Text('Unexpected state'),
        );
      },
    ),
  ),
),

        ],
      ),
    );
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
}
