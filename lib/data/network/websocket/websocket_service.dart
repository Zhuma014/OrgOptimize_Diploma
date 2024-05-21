import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  final WebSocketChannel channel;

  WebSocketService(String url)
      : channel = WebSocketChannel.connect(Uri.parse(url));

  Stream<dynamic> get stream => channel.stream;

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  void close() {
    channel.sink.close(status.goingAway);
  }
}
