import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/ui/theme/palette.dart';

class ClubInfoModal extends StatefulWidget {
  final Club club;

  ClubInfoModal({required this.club});

  @override
  _ClubInfoModalState createState() => _ClubInfoModalState();
}

class _ClubInfoModalState extends State<ClubInfoModal> {
  late Future<UserProfile?> _adminProfile;

  @override
  void initState() {
    super.initState();
    _adminProfile = ooBloc.getUserProfileById(widget.club.adminId!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: FutureBuilder<UserProfile?>(
        future: _adminProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching admin profile: ${snapshot.error}'),
            );
          }

          final adminProfile = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.club.name!,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Palette.MAIN,
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    'ID: ',
                    style: TextStyle(
                      color: Palette.MAIN.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${widget.club.id}',
                    style: TextStyle(
                      color: Palette.MAIN,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    'Admin: ',
                    style: TextStyle(
                      color: Palette.MAIN.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${adminProfile.fullName}',
                    style: TextStyle(
                      color: Palette.MAIN,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    'Created At: ',
                    style: TextStyle(
                      color: Palette.MAIN.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${widget.club.createdAt!.toString().split(' ')[0]}',
                    style: TextStyle(
                      color: Palette.MAIN,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                widget.club.description!,
                style: TextStyle(
                  color: Palette.MAIN.withOpacity(0.7),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}