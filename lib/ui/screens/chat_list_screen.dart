import 'package:flutter/material.dart';

import 'package:urven/ui/screens/base/base_screen.dart';
import 'package:urven/ui/screens/chat_screen.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/lu.dart';


class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  ChatListScreenState createState() => ChatListScreenState();
}

class ChatListScreenState extends BaseScreenState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Toolbar(
              isBackButtonVisible: false,
              title: LU.of(context).chat,
            ),
          ),

          ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen()),
    );
  },
  child: Text('Go to Chat'),
)

        ],
      ),
    );
  }
}
