import 'package:dahab_app/models/chatMessage';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dahab_app/services/auth_service.dart';
import 'package:signalr_core/signalr_core.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId; 
  const ChatScreen({super.key, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String _fixedReceiverId = 'a072775f-a761-4cb7-84a3-1542facffe0b';
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final AuthService _authService = AuthService();
  late String _currentUserId;
  late HubConnection _hubConnection;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId().then((_) {
      _loadMessages();
      _connectToSignalR();
    });
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString("userId") ?? "";
  }

  Future<void> _loadMessages() async {
    try {
      final history = await _authService.getChatHistory(_currentUserId, _fixedReceiverId);
      setState(() {
        _messages.clear();
        _messages.addAll(history);
        if (_messages.isEmpty) {
          _messages.add(
            ChatMessage(
              senderId: _fixedReceiverId,
              receiverId: _currentUserId,
              content: 'Hello! How can I help you today?',
              timestamp: DateTime.now(),
              isMe: false,
            ),
          );
        }
      });
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  Future<void> _connectToSignalR() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          'https://ahmed-cmgfbvavf6c2c6dg.polandcentral-01.azurewebsites.net/chatHub',
          HttpConnectionOptions(
            accessTokenFactory: () async => token!,
            logging: (level, message) => print(message),
          ),
        )
        .build();

    _hubConnection.onclose((error) {
      print("Connection closed: \$error");
    });

    _hubConnection.on("ReceiveMessage", (arguments) {
      final receivedMessage = ChatMessage(
        senderId: arguments![0],
        receiverId: _currentUserId,
        content: arguments[1],
        timestamp: DateTime.now(),
        isMe: false,
      );

      setState(() {
        _messages.add(receivedMessage);
      });
    });

    await _hubConnection.start();
    print("Connected to SignalR");
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      senderId: _currentUserId,
      receiverId: _fixedReceiverId,
      content: text,
      timestamp: DateTime.now(),
      isMe: true,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _controller.clear();

    final success = await _authService.sendMessage(newMessage);
    if (!success) {
      print("Failed to send message");
    }
  }

  Widget _buildMessage(ChatMessage message) {
    final theme = Theme.of(context);

    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: message.isMe ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isMe)
              Text(
                message.senderId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: message.isMe ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: message.isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: theme.textTheme.bodyLarge!.color),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: theme.hintColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
