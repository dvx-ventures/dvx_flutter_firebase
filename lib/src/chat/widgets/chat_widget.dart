import 'package:flutter/material.dart';
import 'package:dvx_flutter_firebase/src/chat/chat_models.dart';
import 'package:dvx_flutter_firebase/src/chat/widgets/chat_input.dart';
import 'package:dvx_flutter_firebase/src/chat/widgets/message_listview.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    Key? key,
    required this.messages,
    required this.user,
    required this.toUid,
    this.onLongPressAvatar,
    this.onLongPressMessage,
    this.onPressAvatar,
  }) : super(key: key);

  final List<ChatMessage> messages;
  final ChatUser user;
  final String? toUid;
  final Function(ChatUser)? onPressAvatar;
  final Function(ChatUser)? onLongPressAvatar;
  final Function(ChatMessage)? onLongPressMessage;

  @override
  ChatWidgetState createState() => ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  ScrollController? scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController(keepScrollOffset: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MessageListView(
          scrollController: scrollController,
          user: widget.user,
          messages: widget.messages,
          onLongPressAvatar: widget.onLongPressAvatar,
          onPressAvatar: widget.onPressAvatar,
          onLongPressMessage: widget.onLongPressMessage,
        ),
        ChatInput(
          toUid: widget.toUid,
          user: widget.user,
        )
      ],
    );
  }
}
