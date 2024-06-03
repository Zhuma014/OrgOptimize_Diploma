// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/screen_size_configs.dart';

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
  StreamSubscription<List<Club>>? userClubsSubscription;

  @override
  void initState() {
    super.initState();
    ooBloc.getUserProfile();

    ooBloc.getAllClubs();
    ooBloc.getUserClubs();
    _loadPendingRequests();
    searchController.addListener(_filterClubs);

    userClubsSubscription =
        ooBloc.getUserClubsSubject.stream.listen(_updateUserClubs);

  }

  void _updateUserClubs(List<Club> clubs) {
    if (mounted) {
      setState(() {
        userClubs = clubs;
      });
    }
  }

  @override
  void dispose() {
    userClubsSubscription?.cancel();

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
                fontSize: SSC.p20,
              ),
            ),
            content: const Text(
              'Do you really want to join this club?',
              style: TextStyle(
                color: Colors.black,
                fontSize: SSC.p16,
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
                    fontSize: SSC.p16,
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
                    fontSize: SSC.p16,
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
        _savePendingRequests(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your join request is pending."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your join request already exists."),
          ),
        );
      }

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
                padding: EdgeInsets.only(top: SSC.p10),
                child: Toolbar(
                  isBackButtonVisible: true,
                  title: "Clubs",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: SSC.p5, right: SSC.p5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SSC.p10),
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
                              horizontal: SSC.p16,
                              vertical: SSC.p12,
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
                padding: const EdgeInsets.only(left: SSC.p5, right: SSC.p5),
                child: StreamBuilder<List<Club>>(
                  stream: ooBloc.getAllClubsSubject.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            color: Palette.MAIN,
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final clubs = snapshot.data!;
                    List<Club> filteredClubs = clubs.where((club) {
                      return club.name!
                          .toLowerCase()
                          .contains(searchText?.toLowerCase() ?? '');
                    }).toList();

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

                    if (filteredClubs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No clubs available',
                          style: TextStyle(
                            color: Palette.MAIN,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredClubs.length,
                      itemBuilder: (context, index) {
                        final club = filteredClubs[index];
                        final isUserClubMember = isUserMemberOfClub(club.id!);
                        final isPending = isRequestPending(club.id!);
                        final isClubCreatedByUser =
                            club.adminId == ooBloc.userProfileSubject.value?.id;

                        return ListTile(
                          title: Text(
                            club.name!,
                            style: const TextStyle(
                              color: Palette.MAIN,
                              fontSize: SSC.p18,
                            ),
                          ),
                          subtitle: Text(
                            club.description!,
                            style: const TextStyle(
                              color: Palette.DARK_BLUE,
                              fontSize: SSC.p14,
                            ),
                          ),
                          trailing: isClubCreatedByUser
                              ? const Text(
                                  'Admin',
                                  style: TextStyle(color: Colors.red),
                                )
                              : isUserClubMember
                                  ? const Text(
                                      'Member',
                                      style: TextStyle(color: Colors.green),
                                    )
                                  : isPending
                                      ? const Text(
                                          'Requested',
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      : const Text('Join',
                                          style: TextStyle(color: Colors.blue)),
                          onTap: isUserClubMember ||
                                  isPending ||
                                  isClubCreatedByUser
                              ? null
                              : () {
                                  _openJoinClubModal(context, club.id!);
                                },
                        );
                      },
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }

  void _openCreateClubModal(BuildContext context) {
    String clubName = '';
    String clubDescription = '';
    bool isButtonEnabled = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Create a Club',
                style: TextStyle(fontSize: SSC.p20, fontWeight: FontWeight.bold),
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
                      labelStyle: const TextStyle(
                        color: Palette.MAIN,
                        fontSize: SSC.p16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: SSC.p10, horizontal: SSC.p16),
                    ),
                  ),
                  const SizedBox(height: SSC.p10),
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
                      labelStyle: const TextStyle(
                        color: Palette.MAIN,
                        fontSize: SSC.p16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Palette.MAIN),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: SSC.p10, horizontal: SSC.p16),
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
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey, fontSize: SSC.p16),
                      ),
                    ),
                    TextButton(
                      onPressed: isButtonEnabled
                          ? () {
                              _performCreateClub(clubName, clubDescription);

                              Navigator.pop(context);
                            }
                          : null,
                      child: const Text(
                        'Create',
                        style: TextStyle(color: Palette.MAIN, fontSize: SSC.p16),
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

  void _performCreateClub(String name, String description) {
    ooBloc.createClub(name: name, description: description);

    ooBloc.createClubSubject.stream.listen((value) {
      if (value.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Club created successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value.exception ?? 'Failed to create club'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
