import 'dart:async';

import 'package:rxdart/subjects.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/data/models/chat/chat_room_member.dart';
import 'package:urven/data/models/chat/message.dart';
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
  BehaviorSubject<List<Event>> getClubEventsSubject = BehaviorSubject();
  BehaviorSubject<List<Event>> getUserOwnedEventsSubject = BehaviorSubject();
  BehaviorSubject<List<Club>> getAllClubsSubject = BehaviorSubject();
  BehaviorSubject<List<Club>> getUserClubsSubject = BehaviorSubject();
  BehaviorSubject<JoinRequest> joinRequestSubject = BehaviorSubject();
  BehaviorSubject<List<JoinRequest>> joinRequestListSubject = BehaviorSubject();
  BehaviorSubject<JoinRequest> approveJoinRequestSubject = BehaviorSubject();
  BehaviorSubject<JoinRequest> rejectJoinRequestSubject = BehaviorSubject();
  BehaviorSubject<List<ChatRoom>> getChatRoomsSubject = BehaviorSubject();
  BehaviorSubject<List<ChatRoomMember>> getChatRoomMembersSubject =
      BehaviorSubject();
final getMessagesListSubject = StreamController<List<Message>>.broadcast();
  Stream<List<Message>> getMessagesListStream() => getMessagesListSubject.stream;


  signIn(String username, String password, {required String fcm_token}) async {
    Logger.d(TAG, 'signInMember() -> $username, $password');

    signInSubject = BehaviorSubject<SignIn>();

    SignIn response = await _repository.signIn(
      username,
      password,
      fcm_token: fcm_token
    );

    if (response.isValid) {
      PreferencesManager.instance.saveAuthCredentials(response.accessToken!);
      getUserProfile(); // Get user's profile after authenticating
    }

    signInSubject.sink.add(response);
  }

  signUp(String email, String password, DateTime birthdate,
      String fullname,{required String fcm_token}) async {
    Logger.d(
        TAG, 'signUpMember() ->  $email, $password, $birthdate, $fullname');

    signUpSubject = BehaviorSubject<SignUp>();

    SignUp response =
        await _repository.signUp(email, password, birthdate, fullname, fcm_token: fcm_token);
    if (response.isValid) {
      PreferencesManager.instance.saveAuthCredentials(response.accessToken!);
      getUserProfile(); // Get user's profile after authenticating

      signUpSubject.sink.add(response);
    }
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
        userId: userId, clubId: clubId); // Pass the token here
    if (!eventSubject.isClosed) {
      eventSubject.sink.add(event);
    }
    ooBloc.getAllUserEvents();
  }

  updateEvent(int eventId, String title, String description, DateTime eventDate,
      String location,
      {dynamic userId, dynamic clubId}) async {
    Logger.d(TAG,
        'updateEvent() -> $eventId, $title, $description, $eventDate, $location');

    Event event = await _repository.updateEvent(
        eventId, title, description, eventDate, location,
        userId: userId, clubId: clubId); // Pass the token here

    // Update the event in your local state if needed
    if (!eventSubject.isClosed) {
      eventSubject.sink.add(event);
    }
  }

  deleteEvent(
    int eventId,
  ) async {
    Logger.d(TAG, 'deleteEvent() -> $eventId');

    bool isDeleted =
        await _repository.deleteEvent(eventId); // Pass the token here

    // Remove the event from your local state if it was successfully deleted
    if (isDeleted && !eventSubject.isClosed) {
      // eventSubject.sink.add(null); // Update the UI to reflect the deletion
    }
  }

  getUserProfile() async {
    UserProfile profile = await _repository.getUserProfile();

    if (profile.exception == null) {
      PreferencesManager.instance.saveUserProfile(profile);

      if (!userProfileSubject.isClosed) {
        userProfileSubject.sink.add(profile);
      }
    } else {
      userProfileSubject.sink.addError(profile.exception!); // Clear user
    }
    ooBloc.getUserClubs();
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

    if (!getAllEventsSubject.isClosed) {
      getAllEventsSubject.sink.add(events);
    }
  }

  getClubEvents() async {
    Logger.d(TAG, 'getOwnEvents()');

    List<Event> clubEvents = await _repository.getClubEvents();

    // Get club names for club events
    for (var event in clubEvents) {
      var club = await getClubById(event.clubId!);
      if (club != null) {
        event.clubName = club.name;
      } else {
        event.clubName = 'Club Not Found';
      }
    }
    if (!getClubEventsSubject.isClosed) {
      getClubEventsSubject.sink.add(clubEvents);
    }
  }

  getOwnEvents() async {
    Logger.d(TAG, 'getOwnEvents()');

    List<Event> userOwnedEvents = await _repository.getOwnEvents();
    if (!getUserOwnedEventsSubject.isClosed) {
      getUserOwnedEventsSubject.sink.add(userOwnedEvents);
    }
  }

  getAllClubs() async {
    Logger.d(TAG, 'getAllClubs()');

    List<Club> clubs = await _repository.getClubs();
    if (!getAllClubsSubject.isClosed) {
      getAllClubsSubject.sink.add(clubs);
    }
  }

  getUserClubs() async {
    Logger.d(TAG, 'getUserClubs()');
    try {
      List<Club> clubs = await _repository.getUserClubs();
      if (!getUserClubsSubject.isClosed) {
        getUserClubsSubject.add(clubs);
      }
    } catch (error) {
      if (!getUserClubsSubject.isClosed) {
        getUserClubsSubject.addError(error);
      }
    }
  }

  getClubById(int clubId) async {
    Logger.d(TAG, 'getClubById()');

    try {
      Club club = await _repository.getClubById(clubId);
      return club;
    } catch (e) {
      Logger.e(TAG, 'Failed to load club: $e');
      return null;
    }
  }

  signOut() async {
    if (!userProfileByIdSubject.isClosed) {
      userProfileSubject.sink.add(null);
    } // Clear user profile
    PreferencesManager.instance.wipeOut(); // Clear preferences
  }

  joinClub(int clubId) async {
    Logger.d(TAG, 'joinClub()');

    if (joinRequestSubject.isClosed) {
      joinRequestSubject = BehaviorSubject<JoinRequest>();
    }

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

  getChatRooms() async {
    Logger.d(TAG, 'getChatRooms()');

    try {
      List<ChatRoom> chatRooms = await _repository.getChatRooms();
      if (!getChatRoomsSubject.isClosed) {
        getChatRoomsSubject.sink.add(chatRooms);
      }
    } catch (e) {
      Logger.d(TAG, 'getChatRooms() -> e:$e');
      if (!getChatRoomsSubject.isClosed) {
        getChatRoomsSubject.sink.addError(e);
      }
    }
  }

  getChatRoomMembers(int roomId) async {
    List<ChatRoomMember> chatRoomMembers =
        await _repository.getChatRoomMembers(roomId);
    if (!getChatRoomMembersSubject.isClosed) {
      getChatRoomMembersSubject.sink.add(chatRoomMembers);
    }
  }

  getChatRoomMessages(int roomId) async {
    List<Message> messages = await _repository.getChatRoomMessages(roomId);

    if (!getMessagesListSubject.isClosed) {
      getMessagesListSubject.sink.add(messages);
    }
  }

  void _closeSubjects(List<BehaviorSubject> subjects) {
    for (var subject in subjects) {
      subject.close();
    }
  }

  dispose() {
    try {
      _closeSubjects([
        signInSubject,
        signUpSubject,
        userProfileSubject,
        userProfileByIdSubject,
        eventSubject,
        getClubEventsSubject,
        getUserOwnedEventsSubject,
        createClubSubject,
        getAllClubsSubject,
        getUserClubsSubject,
        joinRequestSubject,
        signOutSubject,
        joinRequestListSubject,
        approveJoinRequestSubject,
        rejectJoinRequestSubject,
        getChatRoomsSubject,
        getChatRoomMembersSubject,
      ]);
              getMessagesListSubject.close();

    } catch (e) {
      Logger.e(TAG, e.toString());
    }
  }
}

final ooBloc = OrgOptimizeBloc();
