import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/models/chat/chat_room.dart';
import 'package:urven/data/models/chat/chat_room_member.dart';
import 'package:urven/data/models/chat/message.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/data/network/websocket/websocket_service.dart';
import 'package:urven/ui/theme/palette.dart';

class ChatScreen extends StatefulWidget {
  final int chatRoomId;

  ChatScreen({required this.chatRoomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late WebSocketManager _webSocketManager;
  int? currentUserId;
  List<Message> allMessages = [];
  ScrollController _scrollController = ScrollController();
  String neighborName = '';

  @override
  void initState() {
    super.initState();
    _webSocketManager = WebSocketManager(roomId: widget.chatRoomId);

    // Fetch initial messages from the server
    ooBloc.getChatRoomMessages(widget.chatRoomId);

    // Fetch the user profile to get the current userId
    ooBloc.getUserProfile();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.MAIN,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<String>(
              stream: _getChatRoomNameStream(widget.chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                } else if (snapshot.hasError) {
                  return Text('Error');
                } else if (!snapshot.hasData) {
                  return Text('Default Chat Room');
                } else {
                  return Text(snapshot.data!, style: TextStyle(fontSize: 16));
                }
              },
            ),
            SizedBox(height: 4),
            StreamBuilder<String>(
              stream: _getChatRoomMembersStream(widget.chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading members...');
                } else if (snapshot.hasError) {
                  return Text('Error fetching members');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No members');
                } else {
                  return Text('Members: ${snapshot.data}');
                }
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<UserProfile?>(
          stream: ooBloc.userProfileSubject.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Error fetching user profile: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No user profile found'));
            } else {
              UserProfile userProfile = snapshot.data!;
              currentUserId = userProfile.id;

              return Column(children: [
                StreamBuilder<List<Message>>(
                  stream: ooBloc.getMessagesListStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      allMessages = snapshot.data!;
                      _webSocketManager.messageStream.listen((data) {
                        List<String> messageParts = data.split(':');
                        if (messageParts.length >= 2) {
                          int messageUserId =
                              int.tryParse(messageParts[0]) ?? -1;
                          neighborName = messageParts[2];

                          String messageContent =
                              messageParts.skip(1).join(':').trim();

                          if (!allMessages.any((message) =>
                              message.userId == messageUserId &&
                              message.content == messageContent)) {
                            allMessages.add(Message(
                              userId: messageUserId,
                              content: messageContent,
                              timestamp: DateTime
                                  .now(), // Assuming this is the timestamp of the received message
                            ));
                            setState(() {});
                          }
                        }
                      });
                      return Expanded(
                        child: ListView.builder(
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
                                              children: [
                                                Text(
                                                  messageObj.userId ==
                                                          currentUserId
                                                      ? 'You'
                                                      : neighborName,
                                                  style: TextStyle(
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
                                                  padding: const EdgeInsets.all(
                                                      14.0),
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
                                              style: TextStyle(
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
                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Palette.MAIN),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Palette.MAIN),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Container(
                        decoration: BoxDecoration(
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
                              setState(() {});
                              _messageController.clear();

                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                              // Update UI immediately
                              _messageController.clear();
                            }
                          },
                          icon: Icon(Icons.send, color: Colors.white),
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

  Stream<String> _getChatRoomNameStream(int roomId) {
    return ooBloc.getChatRoomsSubject.stream.map((chatRooms) {
      ChatRoom? chatRoom = chatRooms.firstWhere(
        (room) => room.id == roomId,
        orElse: () => ChatRoom(id: -1, name: 'Default Chat Room'),
      );
      return chatRoom.name ?? 'Default Chat Room';
    });
  }

  Stream<String> _getChatRoomMembersStream(int roomId) {
    return ooBloc.getChatRoomMembersSubject.stream
        .asyncMap((List<ChatRoomMember> chatRoomMembers) async {
      List<int> userIds =
          chatRoomMembers.map((member) => member.userId ?? -1).toList();
      print('User IDs: $userIds');

      List<UserProfile?> profiles = await Future.wait(
          userIds.map((userId) => ooBloc.getUserProfileById(userId)));
      print('User Profiles: $profiles');

      List<String> memberNames =
          profiles.map((profile) => profile?.fullName ?? 'Unknown').toList();
      print('Member Names: $memberNames');

      return memberNames.join(', ');
    });
  }

  Widget _buildDateWidget(DateTime timestamp) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          DateFormat('MMM d, yyyy - HH:mm').format(timestamp),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12.0,
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
