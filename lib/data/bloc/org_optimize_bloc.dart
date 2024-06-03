// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:rxdart/subjects.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/data/models/chat/chat_room_member.dart';
import 'package:urven/data/models/chat/message.dart';
import 'package:urven/data/models/club/club_events.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/user/attendance.dart';
import 'package:urven/data/models/user/join_request.dart';
import 'package:urven/data/models/user/sign_in.dart';
import 'package:urven/data/models/user/sign_out.dart';
import 'package:urven/data/models/user/sign_up.dart';
import 'package:urven/data/models/user/user_edit.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/data/network/repository/api_repository.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/utils/logger.dart';

const String TAG = 'OrgOptimizeBloc';

class OrgOptimizeBloc {
  final ApiRepository _repository = ApiRepository();

  BehaviorSubject<SignIn> signInSubject = BehaviorSubject();
  BehaviorSubject<SignUp> signUpSubject = BehaviorSubject();
  BehaviorSubject<SignOut> signOutSubject = BehaviorSubject();
  

  // User
  BehaviorSubject<UserProfile?> userProfileSubject = BehaviorSubject();
  BehaviorSubject<UserProfile?> userProfileByIdSubject = BehaviorSubject();
  BehaviorSubject<dynamic> deleteProfileSubject = BehaviorSubject();
  BehaviorSubject<UserEdit> updateProfileSubject = BehaviorSubject();
  BehaviorSubject<List<UserProfile>> usersSubject = BehaviorSubject();
  
  // Club
  BehaviorSubject<Club> createClubSubject = BehaviorSubject();
  BehaviorSubject<Club> updateClubSubject = BehaviorSubject();
  BehaviorSubject<bool> deleteClubSubject = BehaviorSubject();
  BehaviorSubject<bool> leaveClubSubject = BehaviorSubject();
  BehaviorSubject<List<Club>> getAllClubsSubject = BehaviorSubject();
  BehaviorSubject<List<Club>> getUserClubsSubject = BehaviorSubject();
  BehaviorSubject<List<Club>> adminClubsSubject = BehaviorSubject<List<Club>>();
  BehaviorSubject<List<Club>> memberClubsSubject =
  BehaviorSubject<List<Club>>();
  BehaviorSubject<bool> changeAdminSubject = BehaviorSubject();
  BehaviorSubject<bool> deleteMemberSubject = BehaviorSubject();
  BehaviorSubject<List<UserProfile>> membersSubject = BehaviorSubject();



  // Event
  BehaviorSubject<List<Event>> getAllEventsSubject = BehaviorSubject();
  BehaviorSubject<List<Event>> getClubEventsSubject = BehaviorSubject();
  BehaviorSubject<List<Event>> getUserOwnedEventsSubject = BehaviorSubject();
  BehaviorSubject<Event> eventSubject = BehaviorSubject();
  

  // ChatRoom
  BehaviorSubject<ChatRoom> updateChatRoomSubject = BehaviorSubject();
  BehaviorSubject<bool> changeOwnerSubject = BehaviorSubject();
  BehaviorSubject<bool> deleteChatRoomSubject = BehaviorSubject();
  BehaviorSubject<bool> deleteChatRoomMemberSubject = BehaviorSubject();
  BehaviorSubject<bool> leaveChatRoomSubject = BehaviorSubject();
  BehaviorSubject<List<ChatRoom>> getChatRoomsSubject = BehaviorSubject();
  BehaviorSubject<ChatRoom> chatRoomSubject = BehaviorSubject();
  Stream<List<ChatRoom>> get getChatRoomsStream => getChatRoomsSubject.stream;
  BehaviorSubject<List<ChatRoomMember>> getChatRoomMembersSubject = BehaviorSubject();
  BehaviorSubject<List<Message>> _chatRoomMessagesSubject =  BehaviorSubject<List<Message>>();
  Stream<List<Message>> get chatRoomMessagesStream =>
      _chatRoomMessagesSubject.stream;

  // Join Request
  BehaviorSubject<JoinRequest> joinRequestSubject = BehaviorSubject();
  BehaviorSubject<List<JoinRequest>> joinRequestListSubject = BehaviorSubject();
  BehaviorSubject<JoinRequest> approveJoinRequestSubject = BehaviorSubject();
  BehaviorSubject<JoinRequest> rejectJoinRequestSubject = BehaviorSubject();

  // Attendees
  BehaviorSubject<List<Attendance>> attendancesSubject = BehaviorSubject();
  final _attendanceStatusSubject = BehaviorSubject<Map<int, bool>>.seeded({});
  Stream<Map<int, bool>> get attendanceStatusStream =>
      _attendanceStatusSubject.stream;
  Map<int, bool> get attendanceStatus => _attendanceStatusSubject.value;



  signIn(String username, String password, {required String fcm_token}) async {
    Logger.d(TAG, 'signInMember() -> $username, $password');

    signInSubject = BehaviorSubject<SignIn>();

    SignIn response =
        await _repository.signIn(username, password, fcm_token: fcm_token);

    if (response.isValid) {
      PreferencesManager.instance.saveAuthCredentials(response.accessToken!);
      getUserProfile();
    }

    signInSubject.sink.add(response);
  }

  signUp(String email, String password, DateTime birthdate, String fullname,
      {required String fcm_token}) async {
    Logger.d(
        TAG, 'signUpMember() ->  $email, $password, $birthdate, $fullname');

    signUpSubject = BehaviorSubject<SignUp>();

    SignUp response = await _repository
        .signUp(email, password, birthdate, fullname, fcm_token: fcm_token);
    if (response.isValid) {
      PreferencesManager.instance.saveAuthCredentials(response.accessToken!);
      getUserProfile(); 
      signUpSubject.sink.add(response);
    }
  }

  createClub({required String name, required String description}) async {
    try {
      Logger.d(TAG, 'createClub() -> $name, $description');

      if (createClubSubject.isClosed) {
        createClubSubject = BehaviorSubject<Club>();
      }

      Club response = await _repository.createClub(name, description);

      createClubSubject.sink.add(response);

      await getAllClubs();
      await getUserClubs();
    } catch (e) {
      Logger.e(TAG, 'Error in createClub: $e');
    }
  }

  updateClub({
    required int clubId,
    required String name,
    required String description,
  }) async {
    try {
      Logger.d(TAG, 'updateClub() -> $clubId, $name, $description');

      Club club = await _repository.updateClub(clubId, name, description);
      if (updateClubSubject.isClosed) {
        updateClubSubject = BehaviorSubject<Club>();
      }

      updateClubSubject.sink.add(club);
      await getUserClubs();
      return club;
    } catch (e) {
      Logger.e(TAG, 'Error in updateClub: $e');
      updateClubSubject.sink.addError(e);
      return null;
    }
  }

    updateChatRoom({
    required int roomId,
    required String name,
    required String description,
  }) async {
    try {
      Logger.d(TAG, 'updateChatRoom() -> $roomId, $name, $description');

      ChatRoom chatRoom = await _repository.updateChatRoom(roomId, name, description,);
      if (updateChatRoomSubject.isClosed) {
        updateChatRoomSubject = BehaviorSubject<ChatRoom>();
      }

      updateChatRoomSubject.sink.add(chatRoom);
      await getChatRooms();
      return chatRoom;
    } catch (e) {
      Logger.e(TAG, 'Error in updateChatRoom: $e');
      updateChatRoomSubject.sink.addError(e);
      return null;
    }
  }

  deleteClub(int clubId) async {
    Logger.d(TAG, 'deleteClub() -> $clubId');

    try {
      if (deleteClubSubject.isClosed) {
        deleteClubSubject = BehaviorSubject<bool>();
      }
      await _repository.deleteClub(clubId);
      deleteClubSubject.sink.add(true);
      await getUserClubs();
    } catch (e) {
      Logger.d(TAG, 'deleteClub() -> e: $e');
      deleteClubSubject.sink.addError(e.toString());
    }
    getUserClubs();
  }

    deleteChatRoom(int roomId) async {
    Logger.d(TAG, 'deleteChatRoom() -> $roomId');

    try {
      if (deleteChatRoomSubject.isClosed) {
        deleteChatRoomSubject = BehaviorSubject<bool>();
      }
      await _repository.deleteChatRoom(roomId);
      deleteChatRoomSubject.sink.add(true);
      await getChatRooms();
    } catch (e) {
      Logger.d(TAG, 'deleteChatRoom() -> e: $e');
      deleteChatRoomSubject.sink.addError(e.toString());
    }
    getChatRooms();
  }

  leaveClub(int clubId) async {
    try {
      if (leaveClubSubject.isClosed) {
        leaveClubSubject = BehaviorSubject<bool>();
      }

      await _repository.leaveClub(clubId);
      leaveClubSubject.sink.add(true);
      ooBloc.getUserClubs();
    } catch (e) {
      leaveClubSubject.sink.addError(e.toString());
    }
  }

    leaveChatRoom(int roomId) async {
    try {
      if (leaveChatRoomSubject.isClosed) {
        leaveChatRoomSubject = BehaviorSubject<bool>();
      }

      await _repository.leaveChatRoom(roomId);
      leaveChatRoomSubject.sink.add(true);
      ooBloc.getUserClubs();
    } catch (e) {
      leaveChatRoomSubject.sink.addError(e.toString());
    }
  }

  createEvent(
      String title, String description, DateTime eventDate, String location,
      {dynamic userId, dynamic clubId}) async {
    try {
      if (eventSubject.isClosed) {
        eventSubject = BehaviorSubject<Event>();
      }

      Event event = await _repository.createEvent(
          title, description, eventDate, location,
          userId: userId, clubId: clubId);
      eventSubject.sink.add(event);

      List<Event> userOwnedEvents = await _repository.getOwnEvents();
      getUserOwnedEventsSubject.sink.add(userOwnedEvents);

      List<Event> clubEvents = await _repository.getClubEvents();
      getClubEventsSubject.sink.add(clubEvents);
    } catch (e) {
      if (!eventSubject.isClosed) {
        eventSubject.sink.addError(e.toString());
      }
    }
  }

  updateEvent(int eventId, String title, String description, DateTime eventDate,
      String location,
      {dynamic userId, dynamic clubId}) async {
    try {
      Logger.d(TAG,
          'updateEvent() -> $eventId, $title, $description, $eventDate, $location');

      if (eventSubject.isClosed) {
        eventSubject = BehaviorSubject<Event>();
      }

      Event event = await _repository.updateEvent(
          eventId, title, description, eventDate, location,
          userId: userId, clubId: clubId);

      eventSubject.sink.add(event);
      getOwnEvents();
      getClubEvents();
    } catch (e) {
      if (!eventSubject.isClosed) {
        eventSubject.sink.addError(e.toString());
      }
    }
  }

  deleteEvent(
    int eventId,
  ) async {
    Logger.d(TAG, 'deleteEvent() -> $eventId');

    bool isDeleted =
        await _repository.deleteEvent(eventId); 

    if (isDeleted && !eventSubject.isClosed) {
      eventSubject.sink.addError('Event deleted');
    }
    getOwnEvents();
    getClubEvents();
  }

  getUserProfile() async {
    try {
      if (userProfileSubject.isClosed) {
        userProfileSubject = BehaviorSubject<UserProfile>();
      }

      UserProfile profile = await _repository.getUserProfile();

      if (profile.exception == null && !userProfileSubject.isClosed) {
        PreferencesManager.instance.saveUserProfile(profile);
        userProfileSubject.sink.add(profile);
      } else if (!userProfileSubject.isClosed) {
        userProfileSubject.sink.addError(profile.exception!);
      }
    } catch (error) {
      if (!userProfileSubject.isClosed) {
        Logger.e(TAG, 'Error in getUserProfile: $error');
        userProfileSubject.sink.addError(error);
      }
    }
    getUserClubs();
    getOwnEvents();
    getClubEvents();
  }

  Future<UserProfile?> getUserProfileById(int userId) async {
    try {
      if (userProfileByIdSubject.isClosed) {
        userProfileByIdSubject = BehaviorSubject<UserProfile>();
      }

      UserProfile profile = await _repository.getUserProfileById(userId);

      if (profile.exception == null) {
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

  Future<List<UserProfile>> getAllUsers() async {
    if (usersSubject.isClosed) {
      usersSubject = BehaviorSubject<List<UserProfile>>();
    }

    List<UserProfile> users = await _repository.getAllUsers();
    usersSubject.sink.add(users);
    return users;
  }

  Future<List<UserProfile>> getClubMembers(int clubId) async {
    if (membersSubject.isClosed) {
      membersSubject = BehaviorSubject<List<UserProfile>>();
    }

    List<UserProfile> members = await _repository.getClubMembers(clubId);
    membersSubject.sink.add(members);
    return members;
  }

  deleteMember(int clubId, int memberId) async {
    Logger.d(TAG, 'deleteMember() -> clubId: $clubId, memberId: $memberId');

    try {
      await _repository.deleteClubMember(clubId, memberId);
      deleteMemberSubject.sink.add(true);
      getClubMembers(clubId);
    } catch (e) {
      Logger.d(TAG, 'deleteMember() -> e: $e');
      deleteMemberSubject.sink.addError(e.toString());
    }
  }

  deleteChatRoomMember(int roomId, int memberId) async {
    Logger.d(TAG, 'deleteChatRoomMember() -> roomId: $roomId, memberId: $memberId');

    try {
      await _repository.deleteChatRoomMember(roomId, memberId);
      deleteChatRoomMemberSubject.sink.add(true);
      getChatRoomMembers(roomId);
    } catch (e) {
      Logger.d(TAG, 'deleteChatRoomMember() -> e: $e');
      deleteChatRoomMemberSubject.sink.addError(e.toString());
    }
  }

  changeAdmin(int clubId, int newAdminId) async {
    try {
      await _repository.changeAdmin(clubId, newAdminId);
      changeAdminSubject.sink.add(true);
    } catch (e) {
      Logger.d(TAG, 'changeAdmin() -> e: $e');
      changeAdminSubject.sink.add(false);
      throw 'Failed to change admin: $e';
    }
  }

    changeChatRoomOwner(int roomId, int newOwnerId) async {
    try {
      await _repository.changeChatRoomOwner(roomId, newOwnerId);
      changeOwnerSubject.sink.add(true);
    } catch (e) {
      Logger.d(TAG, 'changeOwner() -> e: $e');
      changeOwnerSubject.sink.add(false);
      throw 'Failed to change admin: $e';
    }
  }

  getAllUserEvents() async {
    Logger.d(TAG, 'getAllUserEvents()');
    try {
      if (getAllEventsSubject.isClosed) {
        getAllEventsSubject = BehaviorSubject<List<Event>>();
      }

      List<Event> events = await _repository.getAllUserEvents();

      getAllEventsSubject.sink.add(events);
    } catch (error) {
      Logger.e(TAG, 'Error in getAllUserEvents: $error');
      if (!getAllEventsSubject.isClosed) {
        getAllEventsSubject.sink.addError(error.toString());
      }
    }
  }

  getClubEvents() async {
    try {
      if (getClubEventsSubject.isClosed) {
        getClubEventsSubject = BehaviorSubject<List<Event>>();
      }

      List<Event> clubEvents = await _repository.getClubEvents();

      for (var event in clubEvents) {
        var club = await getClubById(event.clubId!);
        event.clubName = club != null ? club.name : 'Club Not Found';
      }

      if (!getClubEventsSubject.isClosed) {
        getClubEventsSubject.sink.add(clubEvents);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  getOwnEvents() async {
    try {
      if (getUserOwnedEventsSubject.isClosed) {
        getUserOwnedEventsSubject = BehaviorSubject<List<Event>>();
      }

      List<Event> userOwnedEvents = await _repository.getOwnEvents();

      if (!getUserOwnedEventsSubject.isClosed) {
        getUserOwnedEventsSubject.sink.add(userOwnedEvents);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  getAllClubs() async {
    Logger.d(TAG, 'getAllClubs()');

    try {
      if (getAllClubsSubject.isClosed) {
        getAllClubsSubject = BehaviorSubject<List<Club>>();
      }
      List<Club> clubs = await _repository.getClubs();
      getAllClubsSubject.sink.add(clubs);
    } catch (e) {
      Logger.e(TAG, 'Error fetching clubs: $e');
      throw "$e";
    }
  }

  getUserClubs() async {
    Logger.d(TAG, 'getUserClubs()');
    try {
      if (getUserClubsSubject.isClosed) {
        getUserClubsSubject = BehaviorSubject<List<Club>>();
      }
      if (adminClubsSubject.isClosed) {
        adminClubsSubject = BehaviorSubject<List<Club>>();
      }
      if (memberClubsSubject.isClosed) {
        memberClubsSubject = BehaviorSubject<List<Club>>();
      }

      List<Club> clubs = await _repository.getUserClubs();

      List<Club> adminClubs = clubs
          .where((club) => club.adminId == userProfileSubject.value?.id)
          .toList();
      List<Club> memberClubs = clubs
          .where((club) => club.adminId != userProfileSubject.value?.id)
          .toList();

      getUserClubsSubject.sink.add(clubs);
      adminClubsSubject.sink.add(adminClubs);
      memberClubsSubject.sink.add(memberClubs);
    } catch (error) {
      Logger.e(TAG, 'Error in getUserClubs: $error');
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
    if (!userProfileSubject.isClosed) {
      userProfileSubject.sink.add(null);
    } 
    PreferencesManager.instance.wipeOut();
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
    try {
      List<JoinRequest> joinRequests =
          await _repository.getJoinRequests(clubId);

      if (!joinRequestListSubject.isClosed) {
        joinRequestListSubject.sink.add(joinRequests);
      }
    } catch (e) {
      Logger.d(TAG, 'getJoinRequests() -> e: $e');
    }
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

  createChatRoom(String name, String description, String type,
      List<int> chosenMembers) async {
    try {
      if (chatRoomSubject.isClosed) {
        chatRoomSubject = BehaviorSubject<ChatRoom>();
      }

      ChatRoom chatRoom = await _repository.createChatRoom(
          name, description, type, chosenMembers);
      chatRoomSubject.sink.add(chatRoom);
      getChatRooms();
    } catch (e) {
      if (!chatRoomSubject.isClosed) {
        chatRoomSubject.sink.addError(e.toString());
      }
    }
  }

  getChatRooms() async {
    Logger.d(TAG, 'getChatRooms()');

    try {
      if (getChatRoomsSubject.isClosed) {
        getChatRoomsSubject = BehaviorSubject<List<ChatRoom>>();
      }

      List<ChatRoom> chatRooms = await _repository.getChatRooms();

      getChatRoomsSubject.sink.add(chatRooms);
    } catch (e) {
      Logger.d(TAG, 'getChatRooms() -> e:$e');
      if (!getChatRoomsSubject.isClosed) {
        getChatRoomsSubject.sink.addError(e);
      }
    }
  }

  getChatRoomMembers(int roomId) async {
    if (getChatRoomMembersSubject.isClosed) {
      getChatRoomMembersSubject = BehaviorSubject<List<ChatRoomMember>>();
    }
    List<ChatRoomMember> chatRoomMembers =
        await _repository.getChatRoomMembers(roomId);
    getChatRoomMembersSubject.sink.add(chatRoomMembers);
  }

  getChatRoomMessages(int roomId) async {
    if (_chatRoomMessagesSubject.isClosed) {
      _chatRoomMessagesSubject = BehaviorSubject<List<Message>>();
    }

    List<Message> messages = await _repository.getChatRoomMessages(roomId);

    _chatRoomMessagesSubject.sink.add(messages);
  }

  deleteAccount() async {
    deleteProfileSubject = BehaviorSubject<dynamic>();
    deleteProfileSubject.sink.add(await _repository.deleteProfile());
    clearSession();
  }

  userEdit(
    String fullName,
    String birthdate,
  ) async {
    updateProfileSubject = BehaviorSubject<UserEdit>();

    updateProfileSubject.sink
        .add(await _repository.userEdit(fullName, birthdate));
    getUserProfile();
  }

  attendEvent(int eventId) async {
    Logger.d(TAG, 'attendEvent()');

    try {
      await _repository.attendEvent(eventId);
      if (!_attendanceStatusSubject.isClosed) {
        _attendanceStatusSubject.add({...attendanceStatus, eventId: true});
      }
    } catch (e) {
      Logger.e(TAG, 'Failed to attend event: $e');
      rethrow;
    }
  }

  doNotAttendEvent(int eventId) async {
    Logger.d(TAG, 'doNotAttendEvent()');

    try {
      await _repository.doNotAttendEvent(eventId);
      if (!_attendanceStatusSubject.isClosed) {
        _attendanceStatusSubject.add({...attendanceStatus, eventId: false});
      }
    } catch (e) {
      Logger.e(TAG, 'Failed to cancel attendance: $e');
      rethrow;
    }
  }

  getAttendancesForEvent(int eventId) async {
    try {
      List<Attendance> attendances =
          await _repository.getAttendancesForEvent(eventId);
      if (!attendancesSubject.isClosed) {
        attendancesSubject.add(attendances);
      }
      return attendances;
    } catch (e) {
      Logger.e(TAG, 'Failed to fetch attendances for event: $e');
      rethrow;
    }
  }

  clearSession() {
    userProfileSubject.sink.add(null); 
    getClubEventsSubject.sink.add([]);
    getUserOwnedEventsSubject.sink.add([]);
    getUserClubsSubject.sink.add([]);
    getChatRoomsSubject.sink.add([]);
    _chatRoomMessagesSubject.sink.add([]);
  }

  dispose() {
    try {
      signInSubject.close();
      signUpSubject.close();
      userProfileSubject.close();
      userProfileByIdSubject.close();
      eventSubject.close();
      getClubEventsSubject.close();
      getUserOwnedEventsSubject.close();
      createClubSubject.close();
      getAllClubsSubject.close();
      adminClubsSubject.close();
      memberClubsSubject.close();
      getUserClubsSubject.close();
      joinRequestSubject.close();
      signOutSubject.close();
      joinRequestListSubject.close();
      approveJoinRequestSubject.close();
      rejectJoinRequestSubject.close();
      getChatRoomsSubject.close();
      getChatRoomMembersSubject.close();
      _attendanceStatusSubject.close();
      updateProfileSubject.close();
      deleteProfileSubject.close();
      attendancesSubject.close();
      _chatRoomMessagesSubject.close();
      membersSubject.close();
    } catch (e) {
      Logger.e(TAG, e.toString());
    }
  }
}

final ooBloc = OrgOptimizeBloc();
