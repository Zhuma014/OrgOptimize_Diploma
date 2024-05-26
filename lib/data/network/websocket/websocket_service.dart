import 'dart:async';
import 'dart:convert';

import 'package:urven/data/models/chat/message.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;


class WebSocketManager {
  final int roomId;
  late IOWebSocketChannel channel;
  String? accessToken = PreferencesManager.instance.getAccessToken();
  StreamController<String> _messageStreamController = StreamController.broadcast();

  WebSocketManager({required this.roomId}) {
    connect(); // Connect to WebSocket when WebSocketManager is created
  }

  void connect() {
    print('Connecting to WebSocket...');
    channel = IOWebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:8000/chat/ws/$roomId?token=$accessToken'),
    );
    channel.stream.listen(
      (data) {
        print('WebSocket connected! Received: $data');
        // Split the received message to extract the content
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
  // Prevent sending empty messages or messages with just the user ID
  if (message.isEmpty || message == '$userId:') {
    return;
  }

  // Send the message in the format 'userId:messageContent'
  channel.sink.add('$userId:$message');
}

  void disconnect() {
    channel.sink.close();
    _messageStreamController.close();
  }
}
