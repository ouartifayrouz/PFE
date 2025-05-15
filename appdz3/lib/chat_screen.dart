import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chatbot_welcome_screen.dart';
import 'lost_object_screen.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedIndex = 0;
  bool _isAscending = true;

  final Map<String, String> chatNameMapping = {
    "chat_ligne1": "chat Alger - Aéroport Houari-Boumediene",
    "chat_ligne3": "chat Alger - Zéralda",
    "chat_ligne4": "chat Alger - Thénia",
    "chat_ligne5": "chat Alger - El Affroun",
  };

  final Map<String, String> ligneImages = {
    "chat Alger - Aéroport Houari-Boumediene": "assets/images/ligne1.png",
    "chat Alger - Zéralda": "assets/images/ligne3.png",
    "chat Alger - Thénia": "assets/images/ligne4.png",
    "chat Alger - El Affroun": "assets/images/ligne5.png",
  };

  final List<Color> gradientColors = [
    Color(0xFFA4C6A8),
    Color(0xFFF4D9DE),
    Color(0xFFDDD7E8),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: gradientColors.first,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Discussions des lignes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              "Accédez aux salons de discussion",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isAscending ? Icons.arrow_downward : Icons.arrow_upward,
              color: isDark ? Colors.white70 : Color(0x8C000000),
            ),
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending;
              });
            },
          )
        ],
      ),
      backgroundColor: isDark ? Colors.black : Color(0xCBE9EBF3),
      body: Column(
        children: [
          Container(
            color: isDark ? Colors.grey[900] : Color(0xCBE9EBF3),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildTopButton("Salons", 0, isDark),
                _buildTopButton("Assistant", 1, isDark),
                _buildTopButton("Objets perdus", 2, isDark),
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? _buildChatList(isDark)
                : _selectedIndex == 1
                ? ChatbotWelcomeScreen()
                : LostObjectFormScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(String label, int index, bool isDark) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor:
            isSelected ? Color(0xFFAFD6B3) : Theme.of(context).cardColor,
            foregroundColor: isSelected
                ? Colors.black87
                : isDark
                ? Colors.white70
                : Theme.of(context).textTheme.bodyMedium?.color,
            side: BorderSide(color: Theme.of(context).dividerColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildChatList(bool isDark) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chats').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildPlaceholder(isDark);
        }

        var chats = snapshot.data!.docs
            .where((chat) => chat.id != "chat_ligne2")
            .toList();

        if (!_isAscending) chats = chats.reversed.toList();

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            var chat = chats[index];
            String chatId = chat.id;
            String ligne = chatNameMapping[chatId] ?? "Chat inconnu";

            return StreamBuilder(
              stream: chat.reference
                  .collection("messages")
                  .orderBy("timestamp", descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> messageSnapshot) {
                if (!messageSnapshot.hasData ||
                    messageSnapshot.data!.docs.isEmpty) {
                  return _buildChatCard(
                      ligne, "Aucun message", "--:--", chatId, index, isDark);
                }

                var lastMessage = messageSnapshot.data!.docs.first;
                String message = lastMessage["text"] ?? "Aucun message";
                String time = lastMessage["timestamp"] != null
                    ? DateFormat('HH:mm')
                    .format(lastMessage["timestamp"].toDate())
                    : "--:--";

                return _buildChatCard(
                    ligne, message, time, chatId, index, isDark);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatCard(String ligne, String message, String time,
      String chatId, int index, bool isDark) {
    Color cardColor = isDark
        ? Colors.grey[850]!
        : (index % 2 == 0 ? Color(0xFFE8ECEAFF) : Color(0xFFDDD7E8FF));

    return Card(
      color: cardColor,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            ligneImages[ligne] ?? 'assets/images/default.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          ligne,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        trailing: Text(
          time,
          style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600]),
        ),
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          final username = prefs.getString('username') ?? 'Inconnu';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                chatId: chatId,
                username: username,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Center(
      child: Text(
        "Aucune discussion disponible.",
        style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.black54),
      ),
    );
  }
}