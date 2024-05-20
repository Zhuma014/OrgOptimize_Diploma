import 'package:rxdart/subjects.dart';
import 'package:urven/data/models/club/club_events.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/user/join_request.dart';
import 'package:urven/data/models/user/sign_in.dart';
import 'package:urven/data/models/user/sign_out.dart';
import 'package:urven/data/models/user/sign_up.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/data/network/repository/api_repository.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/utils/logger.dart';

// ignore: constant_identifier_names
const String TAG = 'OrgOptimizeBloc';

class OrgOptimizeBloc {
  final ApiRepository _repository = ApiRepository();

  // Define signInSubject as a private BehaviorSubject
  BehaviorSubject<SignIn> signInSubject = BehaviorSubject();
  BehaviorSubject<SignUp> signUpSubject = BehaviorSubject();
  BehaviorSubject<UserProfile?> userProfileSubject = BehaviorSubject();
  BehaviorSubject<UserProfile?> userProfileByIdSubject = BehaviorSubject();
  BehaviorSubject<SignOut> signOutSubject = BehaviorSubject();
  BehaviorSubject<Event> eventSubject = BehaviorSubject();
  BehaviorSubject<Club> createClubSubject = BehaviorSubject();
  BehaviorSubject<List<Event>> getAllEventsSubject = BehaviorSubject();
  BehaviorSubject<List<Club>> getAllClubsSubject = BehaviorSubject();
  BehaviorSubject<List<Club>> getUserClubsSubject = BehaviorSubject();
  BehaviorSubject<JoinRequest> joinRequestSubject = BehaviorSubject();
  BehaviorSubject<List<JoinRequest>> joinRequestListSubject = BehaviorSubject();
  BehaviorSubject<JoinRequest> approveJoinRequestSubject = BehaviorSubject();
  BehaviorSubject<JoinRequest> rejectJoinRequestSubject = BehaviorSubject();

  signIn(String username, String password) async {
    Logger.d(TAG, 'signInMember() -> $username, $password');

    signInSubject = BehaviorSubject<SignIn>();

    SignIn response = await _repository.signIn(username, password);

    if (response.isValid) {
      PreferencesManager.instance.saveAuthCredentials(response.accessToken!);
      getUserProfile(); // Get user's profile after authenticating
    }

    signInSubject.sink.add(response);
  }

  signUp(String email, String password, DateTime birthdate,
      String fullname) async {
    Logger.d(
        TAG, 'signUpMember() ->  $email, $password, $birthdate, $fullname');

    signUpSubject = BehaviorSubject<SignUp>();

    SignUp response =
        await _repository.signUp(email, password, birthdate, fullname);

    signUpSubject.sink.add(response);
  }

  createClub({required String name, required String description}) async {
    Logger.d(TAG, 'createClub() -> $name, $description');

    createClubSubject = BehaviorSubject<Club>();

    Club response = await _repository.createClub(name, description);

    createClubSubject.sink.add(response);
    ooBloc.getAllClubs();
  }

  createEvent(
      String title, String description, DateTime eventDate, String location,
      {dynamic userId, dynamic clubId}) async {
    Logger.d(
        TAG, 'createEvent() ->  $title, $description, $eventDate, $location');

    Event event = await _repository.createEvent(
        title, description, eventDate, location,
        userId: userId, clubId: clubId);

    eventSubject.sink.add(event);
    ooBloc.getAllUserEvents();
  }

  getUserProfile() async {
    UserProfile profile = await _repository.getUserProfile();

    if (profile.exception == null) {
      PreferencesManager.instance.saveUserProfile(profile);

      userProfileSubject.sink.add(profile);
    } else {
      userProfileSubject.sink.addError(profile.exception!); // Clear user
    }
  }

  Future<UserProfile?> getUserProfileById(int userId) async {
    try {
      UserProfile profile = await _repository.getUserProfileById(userId);
      if (profile.exception == null) {
        PreferencesManager.instance.saveUserProfile(profile);
        userProfileByIdSubject.sink.add(profile);
        return profile;
      } else {
        userProfileByIdSubject.sink.addError(profile.exception!);
        return null;
      }
    } catch (e) {
      userProfileByIdSubject.sink.addError(e);
      return null;
    }
  }

  getAllUserEvents() async {
    Logger.d(TAG, 'getAllUserEvents()');

    List<Event> events = await _repository.getAllUserEvents();
    getAllEventsSubject.sink.add(events);
  }

  getAllClubs() async {
    Logger.d(TAG, 'getAllClubs()');

    List<Club> clubs = await _repository.getClubs();
    getAllClubsSubject.sink.add(clubs);
  }

  getUserClubs() async {
    Logger.d(TAG, 'getUserClubs()');

    List<Club> clubs = await _repository.getUserClubs();
    getUserClubsSubject.sink.add(clubs);
  }

  signOut() async {
    userProfileSubject.sink.add(null); // Clear user
  }

  joinClub(int clubId) async {
    Logger.d(TAG, 'joinClub()');

    JoinRequest joinRequest = await _repository.joinClub(clubId);
    joinRequestSubject.sink.add(joinRequest);
  }

  getJoinRequests(int clubId) async {
    List<JoinRequest> joinRequests = await _repository.getJoinRequests(clubId);
    joinRequestListSubject.sink.add(joinRequests);
  }

  approveJoinRequest(int clubId, int requestId) async {
    JoinRequest joinRequest =
        await _repository.approveJoinRequest(clubId, requestId);
    approveJoinRequestSubject.sink.add(joinRequest);
  }

  rejectJoinRequest(int clubId, int requestId) async {
    JoinRequest joinRequest =
        await _repository.rejectJoinRequest(clubId, requestId);
    rejectJoinRequestSubject.sink.add(joinRequest);
  }

  // getClubEvents() async {
  //   clubEventsSubject = BehaviorSubject<EventsResponse>();
  //   clubEventsSubject.sink.add(await _repository.getClubEvents());
  // }

  dispose() {
    try {
      signInSubject.close();
      signUpSubject.close();
      userProfileSubject.close();
      userProfileByIdSubject.close();
      eventSubject.close();
      getAllEventsSubject.close();
      createClubSubject.close();
      getAllClubsSubject.close;
      getUserClubsSubject.close();
      joinRequestSubject.close();
      signOutSubject.close();
      joinRequestListSubject.close();
      approveJoinRequestSubject.close();
      rejectJoinRequestSubject.close();
    } catch (e) {
      Logger.e(TAG, e.toString());
    }
  }
}

final ooBloc = OrgOptimizeBloc();
