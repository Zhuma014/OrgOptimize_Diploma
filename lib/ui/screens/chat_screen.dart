import 'package:flutter/material.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late IOWebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel = IOWebSocketChannel.connect('ws://192.168.1.1:8000/chat/ws/2'); // Use your actual user ID here

   _channel.stream.listen((message) {
  try {
    final parts = message.split(':');
    if (parts.length >= 2) {
      final jsonPart = parts.sublist(1).join(':').trim();
      final decodedMessage = json.decode(jsonPart);
      setState(() {
        _messages.add({
          'userName': decodedMessage['userName'],
          'message': decodedMessage['message'],
        });
      });
    } else {
      print('Invalid message format: $message');
    }
  } catch (e) {
    print('Error parsing message: $e');
  }
});

  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final message = {
        'userName': 'Flutter User', // Set the username of the sender
        'message': _controller.text,
      };
      _channel.sink.add(jsonEncode(message));
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(
                    message['userName'] ?? 'Unknown',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(message['message'] ?? ''),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Send a message',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

