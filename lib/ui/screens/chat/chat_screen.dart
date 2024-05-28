// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/chat/message.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/data/network/websocket/websocket_service.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/chat_app_bar.dart';

class ChatScreen extends StatefulWidget {
  final int chatRoomId;

  const ChatScreen({super.key, required this.chatRoomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late WebSocketManager _webSocketManager;
  int? currentUserId;
  List<Message> allMessages = [];
  ScrollController _scrollController = ScrollController();
  Map<int, String> userIdToName = {};

  @override
  void initState() {
    super.initState();
    _webSocketManager = WebSocketManager(roomId: widget.chatRoomId);

    ooBloc.getChatRoomMessages(widget.chatRoomId);
    ooBloc.getChatRoomMembers(widget.chatRoomId);

      getChatRoomMembers();


    ooBloc.getUserProfile();
    _scrollController = ScrollController();
  }

void getChatRoomMembers() {
  ooBloc.getChatRoomMembersSubject.listen((members) {
    if (mounted) {
      setState(() {
        userIdToName = {
          for (var member in members)
            member.id!: member.fullName ?? 'Unknown'
        };
      });
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
        chatRoomId: widget.chatRoomId,
      ),
      body: StreamBuilder<UserProfile?>(
          stream: ooBloc.userProfileSubject,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Error fetching user profile: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No user profile found'));
            } else {
              UserProfile userProfile = snapshot.data!;
              currentUserId = userProfile.id;

              return Column(children: [
                Expanded(
                  child: StreamBuilder<List<Message>>(
                    stream: ooBloc.getMessagesListStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return Center(
                              child: Text(
                            'Start a conversation...',
                            style: TextStyle(
                                color: Palette.DARK_GREY_2.withOpacity(0.6)),
                          ));
                        }
                        allMessages = snapshot.data!;
                        _webSocketManager.messageStream.listen((data) {
                          List<String> messageParts = data.split(':');
                          if (messageParts.length >= 2) {
                            int messageUserId =
                                int.tryParse(messageParts[0]) ?? -1;
                            String messageContent =
                                messageParts.skip(1).join(':').trim();

                            if (!allMessages.any((message) =>
                                message.userId == messageUserId &&
                                message.content == messageContent)) {
                              String userName =
                                  userIdToName[messageUserId] ?? 'Unknown';
                              allMessages.add(Message(
                                userId: messageUserId,
                                content: messageContent,
                                timestamp: DateTime.now(),
                                userName: userName,
                              ));
                              setState(() {});
                            }
                          }
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: allMessages.length,
                          itemBuilder: (context, index) {
                            Message messageObj = allMessages[index];

                            String messageContent = messageObj.content != null
                                ? messageObj.content!.split(':').last.trim()
                                : ''; // Or any default value you want to use

                            bool showDate = true;
                            if (index > 0 &&
                                allMessages[index - 1].timestamp != null &&
                                messageObj.timestamp != null &&
                                isSameDay(allMessages[index - 1].timestamp!,
                                    messageObj.timestamp!)) {
                              showDate = false;
                            }

                            return Column(
                              children: [
                                if (showDate)
                                  if (showDate && messageObj.timestamp != null)
                                    _buildDateWidget(messageObj.timestamp!),
                                Align(
                                  alignment: messageObj.userId == currentUserId
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width /
                                                2,
                                      ),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center ,
                                              children: [
                                                Text(
                                                  messageObj.userId ==
                                                          currentUserId
                                                      ? 'You'
                                                      : userIdToName[messageObj
                                                              .userId] ??
                                                          'Unknown',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: messageObj.userId ==
                                                            currentUserId
                                                        ? Palette.MAIN
                                                            .withOpacity(0.3)
                                                        : Palette.DARK_GREY_2
                                                            .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal:20,vertical: 14
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(messageContent),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            right: 12,
                                            child: Text(
                                              messageObj.timestamp != null
                                                  ? DateFormat('HH:mm').format(
                                                      messageObj.timestamp!)
                                                  : '',
                                              style: const TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        return Center(
                              child: Text(
                            'Start a conversation...',
                            style: TextStyle(
                                color: Palette.DARK_GREY_2.withOpacity(0.6)),
                          ));
                      }
              
                     
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Type a message...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Palette.MAIN),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Palette.MAIN),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        decoration: const BoxDecoration(
                          color: Palette.MAIN,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            String message = _messageController.text.trim();
                            if (message.isNotEmpty) {
                              int userId = userProfile.id!;
                              _webSocketManager.sendMessage(userId, message);
                              allMessages.add(Message(
                                userId: userId,
                                content: message,
                                timestamp: DateTime.now(),
                              ));
                              _messageController.clear();

                            WidgetsBinding.instance.addPostFrameCallback((_) {
  if (_scrollController.hasClients) {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
});
                              setState(() {});

                              // Update UI immediately
                            }
                          },
                          icon: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ]);
            }
          }),
    );
  }

  Widget _buildDateWidget(DateTime timestamp) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          DateFormat('MMM d, yyyy').format(timestamp),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  bool isSameDay(DateTime? date1, DateTime? date2) {
    return date1 != null &&
        date2 != null &&
        date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _webSocketManager.disconnect();
  }
}
