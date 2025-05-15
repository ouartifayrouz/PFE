import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserInfoPage({required this.userData, Key? key}) : super(key: key);

  final Color primaryColor = const Color(0x998BB1FF);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          "Profil utilisateur",
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context, isDark),
          const SizedBox(height: 20),
          _buildInfoTile(Icons.person, "Nom", userData['nom'] ?? "Non renseigné", isDark),
          _buildInfoTile(Icons.badge, "Prénom", userData['prenom'] ?? "Non renseigné", isDark),
          _buildInfoTile(Icons.account_circle, "Nom d'utilisateur", userData['username'] ?? "Non renseigné", isDark),
          _buildInfoTile(Icons.email, "Email", userData['email'] ?? "Non renseigné", isDark),
          _buildInfoTile(Icons.wc, "Sexe", userData['sexe'] ?? "Non renseigné", isDark),
          _buildInfoTile(Icons.work, "Emploi", userData['emploi'] ?? "Non renseigné", isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: primaryColor.withOpacity(0.2),
          child: Icon(Icons.person, size: 50, color: isDark ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 12),
        Text(
          (userData['nom'] != null && userData['prenom'] != null)
              ? "${userData['prenom']} ${userData['nom']}"
              : "Utilisateur inconnu",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, bool isDark) {
    return Card(
      color: isDark ? Colors.grey[900] : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.white : Colors.black),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }
}
