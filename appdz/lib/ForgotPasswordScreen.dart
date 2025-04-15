import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assurez-vous que Firestore est correctement configuré
import 'VerifyEmailScreen.dart'; // Importer la page de vérification

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController(); // Ajout d'un contrôleur pour le champ e-mail

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mot de passe oublié')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/image-backround2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Veuillez entrer votre adresse e-mail pour recevoir un code de vérification.',
                  style: TextStyle(color: Colors.black87, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController, // Lié le contrôleur au champ
                  decoration: InputDecoration(
                    labelText: 'Adresse e-mail',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String email = emailController.text.trim();

                    QuerySnapshot snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: email)
                        .get();

                    if (snapshot.docs.isNotEmpty) {
                      DocumentSnapshot userDoc = snapshot.docs.first;
                      DocumentReference userRef = userDoc.reference;

                      // Récupérer le dernier code (ou le compteur actuel)
                      int currentCounter = userDoc.get('resetCounter') ?? 0;

                      // Incrémenter le compteur
                      int newVerificationCode = currentCounter + 1;

                      // Mettre à jour Firestore avec le nouveau code
                      await userRef.update({'resetCounter': newVerificationCode});

                      // Envoyer le code par mail
                      await sendVerificationEmail(email, newVerificationCode);

                      // Aller à la page de vérification
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerifyEmailScreen(
                            verificationCode: newVerificationCode,
                            email: email,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cette adresse e-mail n\'est pas enregistrée.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 120.0, vertical: 12.0),
                  ),
                  child: Text('Envoyer le code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int generateVerificationCode() {
    // Générer un code de vérification aléatoire à 4 chiffres
    return (1000 + (9999 - 1000) * (new DateTime.now().millisecond / 1000)).floor();
  }

  Future<void> sendVerificationEmail(String email, int code) async {
    // Logique d'envoi d'e-mail. Vous devez configurer cela sur votre serveur.
    // Ici, nous ne ferons pas réellement l'envoi, mais ça pourrait utiliser un service comme Firebase Cloud Functions, SendGrid, etc.
    print('Code de vérification envoyé à $email: $code'); // Simuler l'envoi de l'e-mail pour le développement
  }
}