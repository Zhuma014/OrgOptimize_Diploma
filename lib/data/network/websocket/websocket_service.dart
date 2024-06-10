// ignore_for_file: prefer_final_fields

import 'dart:async';

import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  final int roomId;
  late IOWebSocketChannel channel;
  String? accessToken = PreferencesManager.instance.getAccessToken();
  StreamController<String> _messageStreamController =
      StreamController.broadcast();

  WebSocketManager({required this.roomId}) {
    connect();
  }

  void connect() {
    print('Connecting to WebSocket...');
    channel = IOWebSocketChannel.connect(
      Uri.parse('ws://fastapi-backend-diploma-f151c1772bca.herokuapp.com/chat/ws/$roomId?token=$accessToken'),
    );
    channel.stream.listen(
      (data) {
        print('WebSocket connected! Received: $data');
        try {
          String content = data.split(':').skip(1).join(':').trim();
          _messageStreamController.add(content);
        } catch (e) {
          print('Error parsing message: $e');
        }
      },
      onError: (error, stackTrace) {
        print('Error connecting to WebSocket: $error');
      },
      onDone: () {
        print('WebSocket connection closed.');
      },
    );
  }

  Stream<String> get messageStream => _messageStreamController.stream;

  void sendMessage(int userId, String message) {
    if (message.isEmpty || message == '$userId:') {
      return;
    }

    channel.sink.add('$userId:$message');
    ooBloc.getChatRoomMessages(roomId);
  }

  void disconnect() {
    channel.sink.close();
    _messageStreamController.close();
  }
}
