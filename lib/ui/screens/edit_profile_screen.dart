import 'dart:core';

// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urven/app.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/ui/screens/base/base_screen.dart';
import 'package:urven/ui/widgets/action_button.dart';
import 'package:urven/ui/widgets/common_input_field.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';
import 'package:urven/wrapper.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends BaseScreenState<EditProfileScreen> {
  final formKey = GlobalKey<FormState>();

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
        }
      });
    });
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
  (route) => route.isFirst,
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
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: ActionButton.HEIGHT + SSC.p10,
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


}
