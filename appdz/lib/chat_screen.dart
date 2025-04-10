import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'chat_room_screen.dart';
import 'lost_object_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedIndex = 0;

  // Mapping entre ID Firestore et noms des chats
  final Map<String, String> chatNameMapping = {
    "chat_ligne1": "chat Alger - Aéroport Houari-Boumediene",
    "chat_ligne2": "chat Alger - Tizi Ouzou",
    "chat_ligne3": "chat Alger - Zéralda",
    "chat_ligne4": "chat Alger - Thénia",
    "chat_ligne5": "chat Alger - El Affroun",
  };

  // Mapping entre noms et images
  final Map<String, String> ligneImages = {
    "chat Alger - Aéroport Houari-Boumediene": "assets/images/ligne1.png",
    "chat Alger - Tizi Ouzou": "assets/images/ligne2.png",
    "chat Alger - Zéralda": "assets/images/ligne3.png",
    "chat Alger - Thénia": "assets/images/ligne4.png",
    "chat Alger - El Affroun": "assets/images/ligne5.png",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Discussions", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        elevation: 4,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(
            child: _getSelectedScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCategoryItem("Salons", 0),
          _buildCategoryItem("Assistant", 1),
          _buildCategoryItem("Objets perdus", 2),
        ],
      ),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildChatList();
      case 1:
        return _buildPlaceholder();
      case 2:
        return LostObjectFormScreen();
      default:
        return _buildPlaceholder();
    }
  }

  Widget _buildChatList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chats').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildPlaceholder();
        }
        var chats = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            var chat = chats[index];
            String ligneId = chat.id;
            String ligne = chatNameMapping[ligneId] ?? "Chat inconnu";

            return StreamBuilder(
              stream: chat.reference
                  .collection("messages")
                  .orderBy("timestamp", descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> messageSnapshot) {
                if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
                  return _buildChatCard(ligne, "Aucun message", "--:--");
                }
                var lastMessage = messageSnapshot.data!.docs.first;
                String message = lastMessage["text"] ?? "Aucun message";
                String time = lastMessage["timestamp"] != null
                    ? DateFormat('HH:mm').format(lastMessage["timestamp"].toDate())
                    : "--:--";

                return _buildChatCard(ligne, message, time);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatCard(String ligne, String message, String time) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        leading: CircleAvatar(
          backgroundImage: AssetImage(ligneImages[ligne] ?? "assets/images/default.png"),
          radius: 30,
        ),
        title: Text(
          ligne,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo),
        ),
        subtitle: Text(
          message,
          style: TextStyle(color: Colors.black54, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          time,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(chatId: ligne),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: _selectedIndex == index ? Colors.indigo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.indigo),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _selectedIndex == index ? Colors.white : Colors.indigo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Text(
        "Aucune donnée disponible",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}