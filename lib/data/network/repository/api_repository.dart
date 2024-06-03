// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/data/models/chat/chat_room_member.dart';
import 'package:urven/data/models/chat/message.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/user/attendance.dart';
import 'package:urven/data/models/user/join_request.dart';
import 'package:urven/data/models/user/sign_in.dart';
import 'package:urven/data/models/user/sign_up.dart';
import 'package:urven/data/models/user/user_edit.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/data/network/dio_service.dart';
import 'package:urven/data/network/exceptions/api_exception.dart';
import 'package:urven/utils/logger.dart';
import 'package:urven/utils/primitive/dynamic_utils.dart';
import 'package:urven/utils/primitive/string_utils.dart';

import '../../models/club/club_events.dart';

const String TAG = 'ApiRepository';

class ApiRepository {

  static const SIGN_IN = '/login';
  static const SIGN_UP = '/register';
  static const EVENTS = '/events/';
  static const CLUB_EVENTS = '/events/users-club-events';
  static const OWN_EVENTS = '/events/users-own-events';
  static const CLUBS = '/clubs/';
  static const USER_CLUBS = '/clubs/user-clubs';
  static const USER_PROFILE = '/whoami';
  static const USER = '/users/';
  static const JOIN_REQUEST = '/join/';
  static const JOIN_REQUESTS_LIST = '/join/requests/';
  static const APPROVE_JOIN_REQUEST =
      '/join/{club_id}/requests/{request_id}/approve';
  static const REJECT_JOIN_REQUEST =
      '/join/{club_id}/requests/{request_id}/reject';

  static const CHAT_ROOMS = '/chat/rooms';
  static const CHAT_ROOM_MESSAGES = '/chat/rooms/{room_id}/messages';
  static const CHAT_ROOM_MEMBERS = '/chat/rooms/{room_id}/members';
  static const PROFILE_DELETE = '/profile/delete';
  static const PROFILE_UPDATE = '/profile/update';

  factory ApiRepository() => _instance;

  static final ApiRepository _instance = ApiRepository.internal();

  ApiRepository.internal() {
    _dioService = DioService();
  }

  late DioService _dioService;

  Future<SignIn> signIn(String username, String password,
      {required String fcm_token}) async {
    try {
      FormData formData = FormData.fromMap(
          {'username': username, 'password': password, 'fcm_token': fcm_token});

      final response = await _dioService.post(
        path: SIGN_IN,
        data: formData,
      );

      return SignIn.fromJson(response);
    } catch (e) {
      Logger.d(TAG, 'signIn() -> e: $e');
      throw 'Failed to sign in: $e';
    }
  }

  Future<SignUp> signUp(
      String email, String password, DateTime birthdate, String fullname,
      {required String fcm_token}) async {
    try {
      final response = await _dioService.post(
        path: SIGN_UP,
        body: {
          'email': email,
          'password': password,
          'birth_date': birthdate.toIso8601String().substring(0, 10),
          'full_name': fullname,
          'fcm_token': fcm_token
        },
      );
      return SignUp.fromJson(response);
    } catch (e) {
      Logger.d(TAG, 'signUp() -> e: $e');
      throw 'Failed to sign up: $e';
    }
  }

  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _dioService.get(path: USER_PROFILE);
      return UserProfile.fromJson(response);
    } catch (e) {
      Logger.d(TAG, 'getUserProfile() -> e:$e');
      throw 'Failed to get user profile: $e';
    }
  }

  Future<UserProfile> getUserProfileById(int userId) async {
    try {
      final response = await _dioService.get(path: USER + userId.toString());
      return UserProfile.fromJson(response);
    } catch (e) {
      Logger.d(TAG, 'getUserProfileById() -> e:$e');
      throw 'Failed to get user profile by ID: $e';
    }
  }

  Future<List<UserProfile>> getAllUsers() async {
    try {
      final response = await _dioService.get(path: USER);
      if (response is List) {
        final List<UserProfile> users =
            response.map((userJson) => UserProfile.fromJson(userJson)).toList();
        return users;
      } else {
        throw 'Failed to get users: Invalid response type';
      }
    } catch (e) {
      Logger.d(TAG, 'getUsers() -> e:$e');
      throw 'Failed to get users: $e';
    }
  }

  Future<List<UserProfile>> getClubMembers(int clubId) async {
    try {
      final response = await _dioService.get(path: '/clubs/$clubId/members');
      if (response is List) {
        final List<UserProfile> members = response
            .map((memberJson) => UserProfile.fromJson(memberJson))
            .toList();
        return members;
      } else {
        throw 'Failed to get user profiles by club ID: Invalid response type';
      }
    } catch (e) {
      Logger.d('OoBloc', 'getClubMembers() -> e: $e');
      throw 'Failed to get user profiles by club ID: $e';
    }
  }

  Future<void> deleteClubMember(int clubId, int memberId) async {
    try {
      await _dioService.delete(
        path: '$CLUBS/$clubId/members/$memberId',
      );
    } catch (e) {
      Logger.d(TAG, 'deleteMembers() -> e: $e');
      throw _handleError(e.toString());
    }
  }

  Future<void> deleteChatRoomMember(int roomId, int memberId) async {
    try {
      await _dioService.delete(
        path: '$CHAT_ROOMS/$roomId/members/$memberId',
      );
    } catch (e) {
      Logger.d(TAG, 'deleteChatRoomMember() -> e: $e');
      throw _handleError(e.toString());
    }
  }

  Future<void> changeAdmin(int clubId, int newAdminId) async {
    try {
      final requestBody = {
        "new_admin_id": newAdminId,
      };
      await _dioService.put(
        path: '/clubs/$clubId/change_admin',
        body: requestBody,
      );
    } catch (e) {
      Logger.d(TAG, 'changeAdmin() -> e: $e');
      throw 'Failed to change admin: $e'; 
    }
  }

    Future<void> changeChatRoomOwner(int roomId, int newOwnerId) async {
    try {
      final requestBody = {
        "new_owner_id": newOwnerId,
      };
      await _dioService.put(
        path: '$CHAT_ROOMS/$roomId/change_chat_room_owner',
        body: requestBody,
      );
    } catch (e) {
      Logger.d(TAG, 'changeChatRoomOwner() -> e: $e');
      throw 'Failed to change chat room owner: $e'; 
    }
  }

  Future<Club> createClub(String name, String description) async {
    try {
      final response = await _dioService.post(
        path: CLUBS,
        body: {
          'name': name,
          'description': description,
        },
      );
      return Club.fromJson(response);
    } catch (e) {
      Logger.d(TAG, 'createClub() -> e: $e');
      return Club.withError(_handleError(e.toString()));
    }
  }

  Future<Club> updateClub(int clubId, String name, String description) async {
    try {
      final response = await _dioService.put(
        path: '$CLUBS/$clubId',
        body: {
          'name': name,
          'description': description,
        },
      );
      return Club.fromJson(response);
    } catch (e) {
      Logger.d(TAG, 'updateClub() -> e: $e');
      return Club.withError(_handleError(e.toString()));
    }
  }

    Future<ChatRoom> updateChatRoom(int roomId, String name, String description) async {
    try {
      final response = await _dioService.put(
        path: '$CHAT_ROOMS/$roomId',
        body: {
          'name': name,
          'description': description,
          'type': "group",
        },
      );
      return ChatRoom.fromJson(response);
    } catch (e) {
      Logger.d(TAG, 'updateClub() -> e: $e');
      return ChatRoom.withError(_handleError(e.toString()));
    }
  }

  Future<void> deleteClub(int clubId) async {
    try {
      await _dioService.delete(
        path: '$CLUBS/$clubId',
      );
    } catch (e) {
      Logger.d(TAG, 'deleteClub() -> e: $e');
      throw _handleError(e.toString());
    }
  }

    Future<void> deleteChatRoom(int roomId) async {
    try {
      await _dioService.delete(
        path: '$CHAT_ROOMS/$roomId',
      );
    } catch (e) {
      Logger.d(TAG, 'deleteChatRoom() -> e: $e');
      throw _handleError(e.toString());
    }
  }

  Future<bool> leaveClub(int clubId) async {
    try {
      await _dioService.post(path: '/clubs/$clubId/leave');
      return true;
    } catch (e) {
      Logger.d(TAG, 'leaveClub() -> e:$e');
      return false;
    }
  }

    Future<bool> leaveChatRoom(int roomId) async {
    try {
      await _dioService.delete(path: '$CHAT_ROOMS/$roomId/leave');
      return true;
    } catch (e) {
      Logger.d(TAG, 'leaveChatRoom() -> e:$e');
      return false;
    }
  }

  Future<List<Club>> getClubs() async {
    try {
      final response = await _dioService.get(path: CLUBS);

      if (response is List) {
        final List<Club> clubs = response.map((c) => Club.fromJson(c)).toList();
        return clubs;
      } else {
        throw 'Response is not a List';
      }
    } catch (e) {
      Logger.d(TAG, 'getUserClubs() -> e:$e');
      throw 'Failed to fetch clubs: $e';
    }
  }

  Future<List<Club>> getUserClubs() async {
    try {
      final response = await _dioService.get(
        path: USER_CLUBS,
      );

      if (response is List) {
        final List<Club> clubs = response.map((c) => Club.fromJson(c)).toList();
        return clubs;
      } else {
        throw 'Response is not a List';
      }
    } catch (e) {
      Logger.d(TAG, 'getUserClubs() -> e:$e');
      throw 'Failed to fetch clubs: $e';
    }
  }

  Future<Club> getClubById(int clubId) async {
    try {
      return Club.fromJson(
          await _dioService.get(path: CLUBS + clubId.toString()));
    } catch (e) {
      Logger.d(TAG, 'getUserProfile() -> e:$e');
      return Club.withError(_handleError(e));
    }
  }

  Future<Event> createEvent(
      String title, String description, DateTime eventDate, String location,
      {dynamic userId, dynamic clubId}) async {
    try {
      Map<String, dynamic> body = {
        "title": DynamicUtils.parseNullableString(title)?.tryTrim(),
        "description": DynamicUtils.parseNullableString(description)?.tryTrim(),
        "event_date": eventDate.toIso8601String(),
        "location": DynamicUtils.parseNullableString(location)?.tryTrim(),
      };

      if (userId != null) {
        body["user_id"] = userId;
      }

      if (clubId != null) {
        body["club_id"] = clubId;
      }

      return Event.map(await _dioService.post(path: EVENTS, body: body));
    } catch (e) {
      Logger.d(TAG, 'createEvent() -> e:$e');
      throw ApiException(_handleError(e));
    }
  }

  Future<Event> updateEvent(int eventId, String title, String description,
      DateTime eventDate, String location,
      {dynamic userId, dynamic clubId}) async {
    try {
      Map<String, dynamic> body = {
        "title": DynamicUtils.parseNullableString(title)?.tryTrim(),
        "description": DynamicUtils.parseNullableString(description)?.tryTrim(),
        "event_date": eventDate.toIso8601String(),
        "location": DynamicUtils.parseNullableString(location)?.tryTrim(),
      };

      if (userId != null) {
        body["user_id"] = userId;
      }

      if (clubId != null) {
        body["club_id"] = clubId;
      }

      return Event.map(
          await _dioService.put(path: '$EVENTS/$eventId', body: body));
    } catch (e) {
      Logger.d(TAG, 'updateEvent() -> e:$e');
      throw ApiException(_handleError(e));
    }
  }

  Future<bool> deleteEvent(int eventId) async {
    try {
      await _dioService.delete(path: '$EVENTS/$eventId');
      return true;
    } catch (e) {
      Logger.d(TAG, 'deleteEvent() -> e:$e');
      return false;
    }
  }

  Future<List<Event>> getAllUserEvents() async {
    try {
      final response = await _dioService.get(path: EVENTS);
      if (response is List) {
        final List<Event> events =
            response.map<Event>((e) => Event.map(e)).toList();
        return events;
      } else {
        throw 'Response is not a List';
      }
    } catch (e) {
      Logger.d(TAG, 'getAllUserEvents() -> e: $e');
      throw 'Failed to fetch events: $e';
    }
  }

  Future<List<Event>> getClubEvents() async {
    try {
      final response = await _dioService.get(path: CLUB_EVENTS);
      if (response is List) {
        final List<Event> events =
            response.map<Event>((e) => Event.map(e)).toList();
        return events;
      } else {
        throw 'Response is not a List';
      }
    } catch (e) {
      Logger.d(TAG, 'getClubEvents() -> e: $e');
      throw 'Failed to fetch events: $e';
    }
  }

  Future<List<Event>> getOwnEvents() async {
    try {
      final response = await _dioService.get(path: OWN_EVENTS);

      if (response is List) {
        final List<Event> events =
            response.map<Event>((data) => Event.fromJson(data)).toList();
        return events;
      } else {
        throw 'Response is not a List';
      }
    } catch (e) {
      Logger.d(TAG, 'getOwnEvents() -> e: $e');
      throw 'Failed to fetch events: $e';
    }
  }

  Future<JoinRequest> joinClub(int clubId) async {
    try {
      final response = await _dioService.post(
        path: JOIN_REQUEST + clubId.toString(),
        body: {
          'club_id': clubId.toString(),
        },
      );

      return JoinRequest.fromJson(response);
    } catch (e) {
      Logger.d(TAG, 'joinClub() -> e: $e');
      throw 'Failed to join a club: $e'; 
    }
  }

  Future<List<JoinRequest>> getJoinRequests(int clubId) async {
    try {
      final response = await _dioService.get(
        path: JOIN_REQUESTS_LIST + clubId.toString(),
      );

      if (response is List) {
        final List<JoinRequest> joinRequests = response
            .map<JoinRequest>((data) => JoinRequest.fromJson(data))
            .toList();
        return joinRequests;
      } else {
        throw 'Response is not a List';
      }
    } catch (e) {
      Logger.d(TAG, 'getJoinRequests() -> e: $e');
      throw 'Failed to fetch join requests: $e';
    }
  }

  Future<JoinRequest> approveJoinRequest(int clubId, int requestId) async {
    try {
      final response = await _dioService.put(
        path: APPROVE_JOIN_REQUEST
            .replaceFirst('{club_id}', clubId.toString())
            .replaceFirst('{request_id}', requestId.toString()),
      );
      return JoinRequest.fromJson(
          response); 
    } catch (e) {
      Logger.d(TAG, 'approveJoinRequest() -> e: $e');
      throw 'Failed to approve join request: $e'; 
    }
  }

  Future<JoinRequest> rejectJoinRequest(int clubId, int requestId) async {
    try {
      final response = await _dioService.put(
        path: REJECT_JOIN_REQUEST
            .replaceFirst('{club_id}', clubId.toString())
            .replaceFirst('{request_id}', requestId.toString()),
      );
      return JoinRequest.fromJson(
          response); 
    } catch (e) {
      Logger.d(TAG, 'rejectJoinRequest() -> e: $e');
      throw 'Failed to reject join request: $e'; 
    }
  }

  Future<ChatRoom> createChatRoom(String name, String description, String type,
      List<int> chosenMembers) async {
    try {
      Map<String, dynamic> body = {
        "name": name,
        "description": description,
        "type": type, 
        "chosen_members": chosenMembers,
      };

      return ChatRoom.fromJson(
          await _dioService.post(path: CHAT_ROOMS, body: body));
    } catch (e) {
      Logger.d(TAG, 'createChatRoom() -> e:$e');
      throw ApiException(_handleError(e));
    }
  }

  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final response = await _dioService.get(path: CHAT_ROOMS);

      if (response is List) {
        return response.map((json) => ChatRoom.fromJson(json)).toList();
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('detail')) {
          throw Exception(response['detail']);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      Logger.d(TAG, 'getChatRooms() -> e:$e');
      throw 'Failed to fetch chat rooms: $e';
    }
  }

  Future<List<Message>> getChatRoomMessages(int roomId) async {
    try {
      final response = await _dioService.get(
          path:
              CHAT_ROOM_MESSAGES.replaceFirst('{room_id}', roomId.toString()));
      return (response as List).map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      Logger.d(TAG, 'getChatRoomMessages() -> e:$e');
      throw 'Failed to fetch messages: $e';
    }
  }

  Future<List<ChatRoomMember>> getChatRoomMembers(int roomId) async {
    try {
      final response = await _dioService.get(
          path: CHAT_ROOM_MEMBERS.replaceFirst('{room_id}', roomId.toString()));
      return (response as List)
          .map((json) => ChatRoomMember.fromJson(json))
          .toList();
    } catch (e) {
      Logger.d(TAG, 'getChatRoomMembers() -> e:$e');
      throw 'Failed to fetch chat room members  : $e';
    }
  }

  Future<dynamic> deleteProfile() async {
    try {
      return await _dioService.delete(path: PROFILE_DELETE);
    } catch (e) {
      Logger.d(TAG, 'deleteProfile() -> e:$e');
      throw 'Failed to delete profile  : $e';
    }
  }

  Future<UserEdit> userEdit(
    String fullName,
    String birthdate,
  ) async {
    Map<String, dynamic> body = {
      'full_name': fullName,
    };

    if (birthdate.isNotEmpty) {
      body['birth_date'] = birthdate;
    }

    try {
      return UserEdit.map(await _dioService.put(
        path: PROFILE_UPDATE,
        body: body,
      ));
    } catch (e) {
      Logger.d(TAG, 'userEdit() -> e:$e');
      throw 'Failed to update profile  : $e';
    }
  }

  Future<void> attendEvent(int eventId) async {
    try {
      await _dioService.post(path: '/events/$eventId/attend');
    } catch (e) {
      Logger.d(TAG, 'attendEvent() -> e:$e');
      throw 'Failed to attend the event  : $e';
    }
  }

  Future<void> doNotAttendEvent(int eventId) async {
    try {
      await _dioService.delete(path: '/events/$eventId/do_not_attend');
    } catch (e) {
      Logger.d(TAG, 'doNotAttendEvent() -> e:$e');
      throw 'Failed to cancel attendance  : $e';
    }
  }

  Future<List<Attendance>> getAttendancesForEvent(int eventId) async {
    try {
      final response =
          await _dioService.get(path: '/events/$eventId/attendances');
      List<Attendance> attendances =
          (response as List).map((json) => Attendance.fromJson(json)).toList();
      return attendances;
    } catch (e) {
      Logger.e(TAG, 'Failed to get attendances for event: $e');
      rethrow;
    }
  }

  String _handleError(dynamic error) {
    String message = 'Unexpected error occurred = ${error.toString()}';
    if (error is ApiException) {
      message = 'API Exception = ${error.message}';
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Connection timeout with API server';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Send timeout in connection with API server';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Receive timeout in connection with API server';
          break;
        case DioExceptionType.badCertificate:
          message = 'Incorrect certificate';
          break;
        case DioExceptionType.badResponse:
          message =
              'Received invalid status code: ${error.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          message = 'Request to API server was cancelled';
          break;
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
          message =
              'Connection to API server failed due to internet connection';
          break;
      }
    }
    return message;
  }
}
