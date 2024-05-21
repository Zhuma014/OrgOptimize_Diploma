import 'dart:async';
import 'dart:core';

// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urven/app.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/ui/screens/base/base_screen.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/action_button.dart';
import 'package:urven/ui/widgets/club_info_modal.dart';
import 'package:urven/ui/widgets/common_input_field.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends BaseScreenState<EditProfileScreen> {
  final formKey = GlobalKey<FormState>();
StreamSubscription<Club?>? _clubSubscription;

  final TextEditingController controllerFullName = TextEditingController();
  final TextEditingController controllerDateOfBirth = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();


   

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        if (PreferencesManager.instance.isAuthenticated()) {
          ooBloc.getUserProfile();
          ooBloc.getUserClubs();
        }
      });
    });
  }

  @override
  void dispose() {
    _clubSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<UserProfile?>(
        stream: ooBloc.userProfileSubject.stream,
        builder: (context, AsyncSnapshot<UserProfile?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingWidget();
          } else if (snapshot.hasError) {
            return buildLocalErrorWidget(snapshot.error.toString());
          } else if (snapshot.hasData) {
            UserProfile? userProfile = snapshot.data;
            if (userProfile == null) {
              return buildLocalErrorWidget(LU.of(context).unknown_error);
            } else {
              return buildContentWidget(context, userProfile);
            }
          } else {
            return buildLocalErrorWidget(LU.of(context).unknown_error);
          }
        },
      ),
    );
  }

  Widget buildLocalErrorWidget(String error) {
    return buildErrorWidget(
      error,
      actionButton: ActionButton(
        mainText: LU.of(context).action_logout,
        onPressed: () {
          ooBloc.signOut();

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const OrgOptimizeApp()),
            (route) => false,
          );
        },
      ),
    );
  }

  Widget buildContentWidget(BuildContext context, UserProfile profile) {
    controllerFullName.text = profile.fullName ?? '';
    controllerEmail.text = profile.email ?? '';
    controllerDateOfBirth.text = profile.birthDate ?? '';

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom:10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Toolbar(
                    isBackButtonVisible: true,
                    title: LU.of(context).personal_data,
                  ),
                ),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Имя
                      CommonInputField(
                        margin: const EdgeInsets.fromLTRB(
                          SSC.p15,
                          SSC.p5,
                          SSC.p15,
                          SSC.p0,
                        ),
                        labelText: LU.of(context).full_name,
                        controller: controllerFullName,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        readOnly: true,
                      ),
                      const SizedBox(height: SSC.p8),
        
                      /// День рождения
                      CommonInputField(
                        margin: const EdgeInsets.fromLTRB(
                          SSC.p15,
                          SSC.p5,
                          SSC.p15,
                          SSC.p0,
                        ),
                        labelText: LU.of(context).birthday,
                        controller: controllerDateOfBirth,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        readOnly: true,
                      ),
                      const SizedBox(height: SSC.p8),
        
                      /// Электронная почта
                      CommonInputField(
                        margin: const EdgeInsets.fromLTRB(
                          SSC.p15,
                          SSC.p5,
                          SSC.p15,
                          SSC.p0,
                        ),
                        labelText: LU.of(context).email,
                        controller: controllerEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        readOnly: true,
                      ),
                      const SizedBox(height: SSC.p8),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 15.0, right: 15, top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "You are admin of:",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: Palette.MAIN.withOpacity(0.5),
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(height: 5.0),
                            StreamBuilder<List<Club>>(
                              stream: ooBloc.getUserClubsSubject.stream,
                              builder: (context,
                                  AsyncSnapshot<List<Club>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Failed to fetch clubs: ${snapshot.error}',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  List<Club> adminClubs = snapshot.data!
                                      .where((club) =>
                                          club.adminId ==
                                          ooBloc.userProfileSubject.value?.id!)
                                      .toList();
                                  if (adminClubs.isEmpty) {
                                    return Text(
                                      "No admin clubs",
                                      style: TextStyle(
                                        color: Palette.DARK_GREY_2
                                            .withOpacity(0.7),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    );
                                  } else {
                                    return ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: adminClubs.length,
                                      separatorBuilder: (context, index) =>
                                          SizedBox(height: 8.0),
                                      itemBuilder: (context, index) {
                                        Club club = adminClubs[index];
                                        return GestureDetector(
                                          onTap: () {
          _onClubTapped(club);
              },
                                          child: Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Palette.LIGHT_GREY_4,
                                              ),
                                              color: Palette.SOLITUDE,
                                              borderRadius:
                                                  BorderRadius.circular(SSC.p4),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  club.name!,
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Palette.DARK_GREY_2
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                                SizedBox(height: 4.0),
                                                Text(
                                                  club.description!,
                                                  style: TextStyle(
                                                    color: Palette.DARK_GREY_2
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  return Text(
                                    "No admin clubs",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "You are member of:",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: Palette.MAIN.withOpacity(0.5),
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(height: 5.0),
                            StreamBuilder<List<Club>>(
                              stream: ooBloc.getUserClubsSubject.stream,
                              builder: (context,
                                  AsyncSnapshot<List<Club>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Failed to fetch clubs: ${snapshot.error}',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  List<Club> memberClubs = snapshot.data!
                                      .where((club) =>
                                          club.adminId !=
                                          ooBloc.userProfileSubject.value?.id)
                                      .toList();
                                  if (memberClubs.isEmpty) {
                                    return Text(
                                      "No member clubs",
                                      style: TextStyle(
                                        color: Palette.DARK_GREY_2
                                            .withOpacity(0.7),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    );
                                  } else {
                                    return ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: memberClubs.length,
                                      separatorBuilder: (context, index) =>
                                          SizedBox(height: 8.0),
                                      itemBuilder: (context, index) {
                                        Club club = memberClubs[index];
                                        return GestureDetector(
                                          onTap: () {
          _onClubTapped(club);
              },
                                          child: Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Palette.LIGHT_GREY_4,
                                              ),
                                              color: Palette.SOLITUDE,
                                              borderRadius:
                                                  BorderRadius.circular(SSC.p4),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  club.name!,
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Palette.DARK_GREY_2
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                                SizedBox(height: 4.0),
                                                Text(
                                                  club.description!,
                                                  style: TextStyle(
                                                    color: Palette.DARK_GREY_2
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  return Text(
                                    "No member clubs",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

void _onClubTapped(Club club) {

  _clubSubscription?.cancel();

  // Show the modal immediately
  _showClubInfoModal(club);

  
}

void _showClubInfoModal(Club club) {
  showModalBottomSheet(
    context: context,
    builder: (context) => ClubInfoModal(club: club),
  );
}
}
