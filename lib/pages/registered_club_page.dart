import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'firebase_service.dart';
import 'package:provider/provider.dart';
import 'navigation_provider.dart';

class RegisteredClubPage extends StatefulWidget {
  const RegisteredClubPage({Key? key}) : super(key: key);

  @override
  _RegisteredClubPageState createState() => _RegisteredClubPageState();
}

class _RegisteredClubPageState extends State<RegisteredClubPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? clubData;
  String? clubId;
  bool isLoading = true;
  User? currentUser;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _editDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    fetchClubData();
  }

  Future<void> fetchClubData() async {
    User? user = currentUser;
    if (user != null) {
      String userId = user.uid;
      QuerySnapshot clubSnapshot = await FirebaseFirestore.instance
          .collection('club')
          .where('owner_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (clubSnapshot.docs.isNotEmpty) {
        var club = clubSnapshot.docs.first;
        setState(() {
          clubData = club.data() as Map<String, dynamic>?;
          clubId = club.id;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _editDescriptionController.dispose();
    super.dispose();
  }

  Future<void> deleteDescription(String clubId) async {
    await FirebaseFirestore.instance.collection('club').doc(clubId).update({
      'description': '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      clubData?['description'] = '';
    });
  }

  Future<void> _confirmDeleteClub(BuildContext context) async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green[900], // Hintergrund
          title: const Text('Club löschen',
              style: TextStyle(color: Colors.white)), // Weißer Text
          content: const Text('Möchten Sie diesen Club wirklich löschen?',
              style: TextStyle(color: Colors.white)), // Weißer Text
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen',
                  style: TextStyle(color: Colors.white)), // Weißer Text
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Löschen',
                  style: TextStyle(color: Colors.white)), // Weißer Text
              onPressed: () async {
                if (clubId != null) {
                  await FirebaseService.deleteClub(clubId!);
                  Navigator.of(context).pop(); // Schließen des Dialogs

                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.green[900], // Hintergrund
                        title: const Text('Erfolg',
                            style:
                                TextStyle(color: Colors.white)), // Weißer Text
                        content: const Text(
                            'Ihr Club wurde erfolgreich gelöscht',
                            style:
                                TextStyle(color: Colors.white)), // Weißer Text
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK',
                                style: TextStyle(
                                    color: Colors.white)), // Weißer Text
                            onPressed: () async {
                              Navigator.of(context).pop();
                              final appState =
                                  Provider.of<AppState>(context, listen: false);
                              appState.checkAlreadyRegistered();
                              appState.setIndex(0);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900], // AppBar in dunklem Grün
        title: const Text("Ihr registrierter Club",
            style: TextStyle(color: Colors.white)), // Titel in weiß
      ),
      body: Container(
        color: Colors.green[900], // Hintergrundfarbe des gesamten Bildschirms
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: Colors.white)) // Ladeindikator in weiß
            : clubData == null
                ? const Center(
                    child: Text("Kein registrierter Club gefunden.",
                        style: TextStyle(color: Colors.white))) // Text in weiß
                : ListView(
                    children: [
                      ListTile(
                        title: Text(clubData?['name'] ?? 'N/A',
                            style: TextStyle(
                                color: Colors.white)), // Titel in weiß
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${clubData?['street'] ?? 'N/A'} ${clubData?['house_number'] ?? ''}',
                                style: TextStyle(
                                    color: Colors
                                        .white70)), // Adresse in weiß schattiert
                            Text(
                                '${clubData?['zip_code'] ?? 'N/A'} ${clubData?['city'] ?? ''}',
                                style: TextStyle(
                                    color: Colors
                                        .white70)), // Ort in weiß schattiert
                            FutureBuilder<double>(
                              future: FirebaseService.getAverageRating(clubId!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text("Lade Bewertung...",
                                      style: TextStyle(
                                          color: Colors
                                              .white70)); // Lade Bewertung in weiß
                                }
                                final averageRating = snapshot.data ?? 0.0;
                                return Row(
                                  children: [
                                    Text(averageRating.toStringAsFixed(1),
                                        style: TextStyle(
                                            color: Colors
                                                .white70)), // Bewertung in weiß schattiert
                                    const SizedBox(width: 8),
                                    Row(
                                      children: List.generate(5, (index) {
                                        double starRating = index + 1;
                                        double fillPercentage = 0.0;

                                        double remainder =
                                            averageRating - (starRating - 1);
                                        if (remainder >= 0.2 &&
                                            remainder <= 0.4) {
                                          fillPercentage = 0.4;
                                        } else if (remainder == 0.5) {
                                          fillPercentage = 0.5;
                                        } else if (remainder >= 0.6 &&
                                            remainder <= 0.8) {
                                          fillPercentage = 0.6;
                                        } else if (remainder >= 0.9) {
                                          fillPercentage = 1.0;
                                        } else if (remainder > 0) {
                                          fillPercentage = remainder;
                                        }
                                        return Stack(
                                          children: [
                                            const Icon(Icons.star_border,
                                                color: Colors.amber),
                                            ClipRect(
                                              clipper:
                                                  StarClipper(fillPercentage),
                                              child: const Icon(Icons.star,
                                                  color: Colors.amber),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                    FutureBuilder<int>(
                                      future: FirebaseService.getRatingCount(
                                          clubId!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text("...",
                                              style: TextStyle(
                                                  color: Colors
                                                      .white70)); // Lade Bewertung in weiß
                                        }
                                        final ratingCount = snapshot.data ?? 0;
                                        return Text(
                                            ' ($ratingCount Bewertungen)',
                                            style: TextStyle(
                                                color: Colors
                                                    .white70)); // Bewertungen in weiß schattiert
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(
                                height:
                                    20), // Space between ratings and description
                            Text('Beschreibung',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight
                                        .bold)), // Überschrift Beschreibung in weiß
                            FutureBuilder<DocumentSnapshot>(
                              future: clubId != null
                                  ? FirebaseFirestore.instance
                                      .collection('club')
                                      .doc(clubId)
                                      .get()
                                  : Future.value(null),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Text("Lade Beschreibung...",
                                      style: TextStyle(
                                          color: Colors
                                              .white70)); // Lade Beschreibung in weiß
                                }
                                var data = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                if (!data.containsKey('description') ||
                                    data['description'].isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _descriptionController,
                                            style: TextStyle(
                                                color: Colors
                                                    .white), // Text in weiß
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Neue Beschreibung hinzufügen',
                                              hintStyle: TextStyle(
                                                  color: Colors
                                                      .white70), // Hinweistext in weiß schattiert
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .white), // Umrandung in weiß
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.send,
                                              color: Colors
                                                  .white), // Sende-Icon in weiß
                                          onPressed: () {
                                            FirebaseService.updateDescription(
                                                _descriptionController.text,
                                                clubId!);
                                            setState(() {
                                              clubData?['description'] =
                                                  _descriptionController.text;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final description = data['description'];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(description,
                                              style: TextStyle(
                                                  color: Colors
                                                      .white70))), // Beschreibungstext in weiß schattiert
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors
                                                .white), // Bearbeitungs-Icon in weiß
                                        onPressed: () {
                                          _descriptionController.text =
                                              description;
                                          showDialog<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Colors
                                                    .green[900], // Hintergrund
                                                title: const Text(
                                                    'Beschreibung bearbeiten',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white)), // Weißer Text
                                                content: TextField(
                                                  controller:
                                                      _editDescriptionController,
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white), // Text in weiß
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText:
                                                        'Beschreibung bearbeiten',
                                                    hintStyle: TextStyle(
                                                        color: Colors
                                                            .white70), // Hinweistext in weiß
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text(
                                                        'Abbrechen',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white)), // Weißer Text
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text(
                                                        'Speichern',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white)), // Weißer Text
                                                    onPressed: () async {
                                                      await FirebaseService
                                                          .updateDescription(
                                                              _editDescriptionController
                                                                  .text,
                                                              clubId!);
                                                      setState(() {
                                                        clubData?[
                                                                'description'] =
                                                            _editDescriptionController
                                                                .text;
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors
                                                .white), // Lösch-Icon in weiß
                                        onPressed: () {
                                          deleteDescription(
                                              clubId!); // Verwende die neue Methode
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(
                                height:
                                    20), // Space between description and comments section
                            Text('Kommentare',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight
                                        .bold)), // Überschrift Kommentare in weiß
                            const SizedBox(
                                height:
                                    20), // Space between header and comments
                            StreamBuilder<QuerySnapshot>(
                              stream: clubId != null
                                  ? FirebaseService.getComments(clubId!)
                                  : null,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text("Lade Kommentare...",
                                      style: TextStyle(
                                          color: Colors
                                              .white70)); // Lade Kommentare in weiß
                                }
                                final commentsDocs = snapshot.data?.docs ?? [];
                                if (commentsDocs.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: Text(
                                        "Bisher wurde ihr Club noch nicht kommentiert.",
                                        style:
                                            TextStyle(color: Colors.white70)),
                                  );
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: commentsDocs.map((commentDoc) {
                                    final timestamp =
                                        commentDoc['timestamp'] as Timestamp?;
                                    final formattedDate = timestamp != null
                                        ? DateFormat('dd.MM.yyyy')
                                            .format(timestamp.toDate())
                                        : 'Unbekanntes Datum';

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, top: 4.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    commentDoc['userName'] ??
                                                        'Anonym',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                Text(formattedDate,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text("- ",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                Expanded(
                                                    child: Text(
                                                        commentDoc['content'],
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white70))),
                                                if (commentDoc['userId'] ==
                                                    currentUser?.uid)
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red),
                                                    onPressed: () {
                                                      FirebaseService
                                                          .deleteComment(
                                                              clubId!,
                                                              commentDoc.id);
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ]),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () => _confirmDeleteClub(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Club löschen',
                              style: TextStyle(
                                  color: Colors.white)), // Weißer Text
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class StarClipper extends CustomClipper<Rect> {
  final double fillPercentage;

  StarClipper(this.fillPercentage);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fillPercentage, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}
