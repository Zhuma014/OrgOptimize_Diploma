// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';
import 'package:urven/data/models/base/api_result.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/data/models/chat/chat_room_member.dart';
import 'package:urven/data/models/chat/message.dart';
import 'package:urven/data/models/club/club.dart';
import 'package:urven/data/models/user/join_request.dart';
import 'package:urven/data/models/user/sign_in.dart';
import 'package:urven/data/models/user/sign_up.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/data/network/dio_service.dart';
import 'package:urven/data/network/exceptions/api_exception.dart';
import 'package:urven/utils/logger.dart';

import '../../models/club/club_events.dart';

const String TAG = 'ApiRepository';

// #todo max https://pub.dev/packages/upgrader
class ApiRepository {
  // Version status

  // API Token
  static const API_TOKEN_REFRESH = 'auth/refresh';

  // Auth
  static const SIGN_IN = '/login';
  static const SIGN_UP = '/register';
  static const EVENTS = '/events/';
  static const CLUBS = '/clubs/';
  static const USER_CLUBS = '/clubs/user-clubs';
  static const USER_PROFILE = '/whoami';
  static const USER_PROFILE_BY_ID = '/users/';
  static const JOIN_REQUEST = '/join/';
  static const JOIN_REQUESTS_LIST = '/join/requests/';
  static const APPROVE_JOIN_REQUEST = '/join/{club_id}/requests/{request_id}/approve';
  static const REJECT_JOIN_REQUEST = '/join/{club_id}/requests/{request_id}/reject';

  static const CHAT_WS_URL = 'ws://10.0.2.2:8000/chat/ws/';
  static const CHAT_ROOMS = '/chat/rooms';
  static const CHAT_ROOM_MESSAGES = '/chat/rooms/{room_id}/messages';
  static const CHAT_ROOM_MEMBERS = '/chat/rooms/{room_id}/members';



  factory ApiRepository() => _instance;

  static final ApiRepository _instance = ApiRepository.internal();

  ApiRepository.internal() {
    _dioService = DioService();
  }

  late DioService _dioService;

  Future<SignIn> signIn(String username, String password) async {
    try {
      //username = email
      FormData formData = FormData.fromMap({
        'username': username,
        'password': password,
      });

      final response = await _dioService.post(
        path: SIGN_IN,
        data: formData,
      );
      return SignIn.map(response);
    } catch (e) {
      Logger.d(TAG, 'signIn() -> e: $e');
      return SignIn.withError(_handleError(e));
    }
  }

  Future<SignUp> signUp(String email, String password, DateTime birthdate,
      String fullname) async {
    try {
      final response = await _dioService.post(
        path: SIGN_UP,
        body: {
          'email': email,
          'password': password,
          'birth_date': birthdate.toIso8601String().substring(0, 10),
          'full_name': fullname,
        },
      );
      return SignUp.map(response);
    } catch (e) {
      Logger.d(TAG, 'signUp() -> e: $e');
      return SignUp.withError(
          _handleError(e.toString())); // Ensure that e.toString() is not null
    }
  }

  Future<UserProfile> getUserProfile() async {
    try {
      return UserProfile.map(await _dioService.get(path: USER_PROFILE));
    } catch (e) {
      Logger.d(TAG, 'getUserProfile() -> e:$e');
      return UserProfile.withError(_handleError(e));
    }
  }
  
  Future<UserProfile> getUserProfileById(int userId) async {
    try {
      return UserProfile.map(await _dioService.get(path: USER_PROFILE_BY_ID + userId.toString()));
    } catch (e) {
      Logger.d(TAG, 'getUserProfile() -> e:$e');
      return UserProfile.withError(_handleError(e));
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
      return Club.map(response);
    } catch (e) {
      Logger.d(TAG, 'createClub() -> e: $e');
      return Club.withError(_handleError(e.toString()));
    }
  }

  Future<List<Club>> getClubs() async {
    try {
      final response = await _dioService.get(
        path: CLUBS,
      );
      if (response is List) {
        final List<Club> clubs =
            response.map<Club>((c) => Club.map(c)).toList();
        return clubs;
      } else {
        throw 'Response is not a List';
      }
    } catch (e) {
      Logger.d(TAG, 'getClubs() -> e:$e');
      throw 'Failed to fetch clubs: $e';
    }
  }

  Future<List<Club>> getUserClubs() async {
    try {
      final response = await _dioService.get(
        path: USER_CLUBS,
      );
      if (response is List) {
        final List<Club> clubs =
            response.map<Club>((c) => Club.map(c)).toList();
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
      return Club.map(await _dioService.get(path: CLUBS + clubId.toString()));
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
        "title": title,
        "description": description,
        "event_date": eventDate.toIso8601String(),
        "location": location,
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
      return Event.withError(_handleError(e));
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
      Logger.d(TAG, 'getEvents() -> e:$e');
      throw 'Failed to fetch events: $e';
    }
  }

  Future<JoinRequest> joinClub(int clubId) async {
    try {
      final response = await _dioService.post(
        path: JOIN_REQUEST + clubId.toString(), // Convert clubId to a string
        body: {
          'club_id': clubId.toString(), // Convert clubId to a string
        },
      );

      return JoinRequest.map(response);
    } catch (e) {
      Logger.d(TAG, 'joinClub() -> e: $e');
      return JoinRequest.withError(_handleError(e));
    }
  }

Future<List<JoinRequest>> getJoinRequests(int clubId) async {
  try {
    final response = await _dioService.get(
      path: JOIN_REQUESTS_LIST + clubId.toString(),
    );

    if (response is List) {
      final List<JoinRequest> joinRequests =
          response.map<JoinRequest>((data) => JoinRequest.map(data)).toList();
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
      path: APPROVE_JOIN_REQUEST.replaceFirst('{club_id}', clubId.toString())
                                 .replaceFirst('{request_id}', requestId.toString()),
    );
    return JoinRequest.map(response);
  } catch (e) {
    Logger.d(TAG, 'approveJoinRequest() -> e: $e');
    return JoinRequest.withError(_handleError(e));
  }
}

Future<JoinRequest> rejectJoinRequest(int clubId, int requestId) async {
  try {
    final response = await _dioService.put(
      path: REJECT_JOIN_REQUEST.replaceFirst('{club_id}', clubId.toString())
                                 .replaceFirst('{request_id}', requestId.toString()),
    );
    return JoinRequest.map(response);
  } catch (e) {
    Logger.d(TAG, 'rejectJoinRequest() -> e: $e');
    return JoinRequest.withError(_handleError(e));
  }
}

// Chat methods
Future<List<ChatRoom>> getChatRooms() async {
  try {
    final response = await _dioService.get(path: CHAT_ROOMS);

    if (response is List) {
      return response.map((json) => ChatRoom.fromJson(json)).toList();
    } else if (response is Map<String, dynamic>) {
      // Assuming the server returns an error message in a map format
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
      final response = await _dioService.get(path: CHAT_ROOM_MESSAGES.replaceFirst('{room_id}', roomId.toString()));
      return (response as List).map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      Logger.d(TAG, 'getChatRoomMessages() -> e:$e');
    throw 'Failed to fetch messages: $e';
    }
  }

  Future<List<ChatRoomMember>> getChatRoomMembers(int roomId) async {
    try {
      final response = await _dioService.get(path: CHAT_ROOM_MEMBERS.replaceFirst('{room_id}', roomId.toString()));
      return (response as List).map((json) => ChatRoomMember.fromJson(json)).toList();
    } catch (e) {
      Logger.d(TAG, 'getChatRoomMembers() -> e:$e');
    throw 'Failed to fetch chat room members  : $e';
    }
  }

  


  // Future<EventsResponse> getClubEvents() async {
  //   try {
  //     return EventsResponse.map(await _dioService.get(path: CLUB_EVENTS));
  //   } catch (e) {
  //     Logger.d(TAG, 'getClubEvents() -> e:$e');
  //     return EventsResponse.withError(_handleError(e));
  //   }
  // }

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
