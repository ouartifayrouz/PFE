import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GareIntermediaire {
  String gare;
  String heurePassage;
  int id;

  GareIntermediaire({
    required this.gare,
    required this.heurePassage,
    required this.id,
  });

  factory GareIntermediaire.fromMap(Map<String, dynamic> data) {
    return GareIntermediaire(
      gare: data["gare"],
      heurePassage: data["Heure_de_Passage"],
      id: data["id"] ?? 0,
    );
  }
}

class Trajet {
  String gareDepart;
  String gareArrivee;
  String heureDepart;
  String heureArrivee;
  int id;
  String lineId;
  String trainId;
  List<GareIntermediaire> garesIntermediaires;
  int? idDepart;
  int? idArrivee;

  Trajet({
    required this.gareDepart,
    required this.gareArrivee,
    required this.heureDepart,
    required this.heureArrivee,
    required this.id,
    required this.lineId,
    required this.trainId,
    required this.garesIntermediaires,
    this.idDepart,
    this.idArrivee,
  });
}

class ListeTrajetsScreen extends StatelessWidget {
  final String departure;
  final String destination;
  final DateTime date;

  ListeTrajetsScreen({
    required this.departure,
    required this.destination,
    required this.date,
  });

  Future<List<Trajet>> _fetchTrajets() async {
    List<Trajet> trajets = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('TRAJET1').get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        List<GareIntermediaire> garesIntermediaires = [];
        QuerySnapshot garesSnapshot = await doc.reference.collection('Gares_Intermédiaires').get();

        for (var gareDoc in garesSnapshot.docs) {
          garesIntermediaires.add(
            GareIntermediaire.fromMap(gareDoc.data() as Map<String, dynamic>),
          );
        }

        final indexDepart = garesIntermediaires.indexWhere((g) => g.gare == departure);
        final indexArrivee = garesIntermediaires.indexWhere((g) => g.gare == destination);

        if (indexDepart != -1 && indexArrivee != -1 && indexDepart < indexArrivee) {
          final gareDepart = garesIntermediaires[indexDepart];
          final gareArrivee = garesIntermediaires[indexArrivee];

          trajets.add(
            Trajet(
              gareDepart: gareDepart.gare,
              gareArrivee: gareArrivee.gare,
              heureDepart: gareDepart.heurePassage,
              heureArrivee: gareArrivee.heurePassage,
              id: data["ID"],
              lineId: data["lineId"],
              trainId: data["trainId"],
              garesIntermediaires: garesIntermediaires,
              idDepart: gareDepart.id,
              idArrivee: gareArrivee.id,
            ),
          );
        }
      }
    } catch (e) {
      print("Erreur lors de la recherche des trajets : $e");
    }

    return trajets;
  }

  String _calculerDuree(String heureDebut, String heureFin) {
    final format = DateFormat("HH:mm");
    final debut = format.parse(heureDebut);
    final fin = format.parse(heureFin);

    Duration diff = fin.difference(debut);
    if (diff.isNegative) diff += Duration(days: 1);

    final heures = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);

    return '${heures}h ${minutes}min';
  }

  void _afficherDetails(BuildContext context, Trajet trajet) {
    final etapes = trajet.garesIntermediaires
        .where((g) => g.id >= (trajet.idDepart ?? 0) && g.id <= (trajet.idArrivee ?? 0))
        .toList();

    final intermediaires = etapes.sublist(1, etapes.length - 1);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Détails de trajet', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              _buildTrajetGraphique(etapes, intermediaires, context),
              SizedBox(height: 20),
              _buildInfoText("Jour de Circulation:", "Tous les jours sauf vendredis"),
              SizedBox(height: 10),
              _buildInfoText("PRIX:", "200 DA"),
              SizedBox(height: 10),
              _buildFavoriserButton(context),
            ],
          ),
        ),
        actions: _buildDialogActions(context),
      ),
    );
  }

  Widget _buildTrajetGraphique(List<GareIntermediaire> etapes, List<GareIntermediaire> intermediaires, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildGareWidget(etapes.first.gare, Colors.green),
          ...intermediaires.expand((gare) => [
            Container(width: 20, height: 2, color: Colors.blue),
            GestureDetector(
              onTap: () => _showIntermediaireDetails(context, gare),
              child: Icon(Icons.change_history, color: Colors.teal, size: 20),
            ),
          ]),
          Container(width: 20, height: 2, color: Colors.blue),
          _buildGareWidget(etapes.last.gare, Colors.red),
        ],
      ),
    );
  }

  Widget _buildGareWidget(String gare, Color couleur) {
    return Column(
      children: [
        Icon(Icons.circle, color: couleur, size: 24),
        SizedBox(height: 4),
        Text(gare, style: TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  void _showIntermediaireDetails(BuildContext context, GareIntermediaire gare) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Gare intermédiaire"),
        content: Text(gare.gare),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String title, String content) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(text: "$title ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriserButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          // Action de favoris préférés
        },
        icon: Icon(Icons.star_border, color: Colors.grey),
        label: Text("Favoriser ce trajet", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  List<Widget> _buildDialogActions(BuildContext context) {
    return [
      TextButton(
        child: Text("Choisir ce trajet", style: TextStyle(color: Colors.white)),
        style: TextButton.styleFrom(backgroundColor: Colors.pink[200]),
        onPressed: () => Navigator.of(context).pop(),
      ),
      TextButton(
        child: Text("Fermer"),
        style: TextButton.styleFrom(backgroundColor: Colors.lightBlue[100], foregroundColor: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$departure → $destination",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(date),
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Color(0xFF353C67),
      ),
      body: Container(
        color: Colors.white38 , // Fond bleu ciel
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              color: Colors.white10,
              width: double.infinity,
              child: Text(
                "Choisissez un trajet qui vous convient le mieux",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Trajet>>(
                future: _fetchTrajets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(child: Text("Erreur: ${snapshot.error}"));
                  if (!snapshot.hasData || snapshot.data!.isEmpty)
                    return Center(child: Text("Aucun trajet trouvé."));

                  List<Trajet> trajets = snapshot.data!;
                  return ListView.builder(
                    itemCount: trajets.length,
                    itemBuilder: (context, index) {
                      final trajet = trajets[index];

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/sntf_logo.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Trajet : ${trajet.id.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    trajet.heureDepart,
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Divider(color: Colors.grey, thickness: 1),
                                    ),
                                  ),
                                  Text(
                                    _calculerDuree(trajet.heureDepart, trajet.heureArrivee),
                                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Divider(color: Colors.grey, thickness: 1),
                                    ),
                                  ),
                                  Text(
                                    trajet.heureArrivee,
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(trajet.gareDepart, style: TextStyle(color: Colors.indigo)),
                                  Text(trajet.gareArrivee, style: TextStyle(color: Colors.indigo)),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("TRAIN: ${trajet.trainId}", style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text("Ligne: ${trajet.lineId}", style: TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.info_outline),
                                  label: Text("Voir détails"),
                                  onPressed: () => _afficherDetails(context, trajet),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[100],
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
