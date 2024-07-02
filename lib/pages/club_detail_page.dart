import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'package:intl/intl.dart';

class ClubDetailPage extends StatefulWidget {
  final Map<String, dynamic> club;

  ClubDetailPage({Key? key, required this.club}) : super(key: key);

  @override
  _ClubDetailPageState createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  String? clubId;
  bool isLoading = true;
  User? currentUser;
  String? description;

  @override
  void initState() {
    super.initState();
    clubId = widget.club['id'];
    currentUser = _auth.currentUser;
    fetchClubDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> fetchClubDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      var clubDoc =
          await FirebaseFirestore.instance.collection('club').doc(clubId).get();
      var clubData = clubDoc.data();
      if (clubData != null) {
        setState(() {
          description = clubData['description'];
        });
      }
    } catch (e) {
      print("Failed to fetch club details: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> addComment() async {
    if (clubId == null || _commentController.text.trim().isEmpty) {
      print("Cannot add comment: clubId or comment content is null/empty");
      return;
    }
    print("Adding comment: ${_commentController.text.trim()}");

    await FirebaseService.addComment(clubId!, _commentController.text.trim());

    print("Comment added successfully.");

    _commentController.clear();
    setState(() {});
  }

  Future<void> deleteComment(String commentId) async {
    if (clubId == null) return;
    await FirebaseService.deleteComment(clubId!, commentId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final clubData = widget.club['data'];
    final String clubDescription = description?.trim().isNotEmpty == true
        ? description!
        : "Der Besitzer hat bisher keine Beschreibung hinzugefügt";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900], // AppBar in dunklem Grün
        title: Text(clubData['name'] ?? 'Club Details',
            style: TextStyle(color: Colors.white)), // Titel in weiß
      ),
      body: Container(
        color: Colors.green[900], // Hintergrundfarbe des gesamten Screens
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: Colors.white)) // Ladeindikator in weiß
            : clubId == null || clubData == null
                ? const Center(
                    child: Text("Bisher wurde noch kein Club registriert.",
                        style: TextStyle(color: Colors.white))) // Text in weiß
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          children: [
                            ListTile(
                              title: Text(clubData['name'] ?? 'N/A',
                                  style: TextStyle(
                                      color: Colors.white)), // Titel in weiß
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${clubData['street'] ?? 'N/A'} ${clubData['house_number'] ?? ''}',
                                      style: TextStyle(
                                          color: Colors.white70)), // Adresse
                                  Text(
                                      '${clubData['zip_code'] ?? 'N/A'} ${clubData['city'] ?? ''}',
                                      style: TextStyle(
                                          color: Colors.white70)), // Ort
                                  FutureBuilder<double>(
                                    future: widget.club['id'] != null
                                        ? getAverageRating(widget.club['id'])
                                        : Future.value(0.0),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text("Lade Bewertung...",
                                            style: TextStyle(
                                                color: Colors
                                                    .white70)); // Lade Bewertung in weiß
                                      }
                                      final averageRating =
                                          snapshot.data ?? 0.0;
                                      return Row(
                                        children: [
                                          Text(averageRating.toStringAsFixed(1),
                                              style: TextStyle(
                                                  color: Colors
                                                      .white70)), // Bewertung
                                          const SizedBox(width: 8),
                                          Row(
                                            children: List.generate(5, (index) {
                                              double starRating = index + 1;
                                              double fillPercentage = 0.0;

                                              double remainder = averageRating -
                                                  (starRating - 1);
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
                                                    clipper: StarClipper(
                                                        fillPercentage),
                                                    child: const Icon(
                                                        Icons.star,
                                                        color: Colors.amber),
                                                  ),
                                                ],
                                              );
                                            }),
                                          ),
                                          FutureBuilder<int>(
                                            future: widget.club['id'] != null
                                                ? getRatingCount(
                                                    widget.club['id']!)
                                                : Future.value(0),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Text("...",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white70)); // Lade Bewertung in weiß
                                              }
                                              final ratingCount =
                                                  snapshot.data ?? 0;
                                              return Text(
                                                  ' ($ratingCount Bewertungen)',
                                                  style: TextStyle(
                                                      color: Colors.white70));
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Text('Beschreibung',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight
                                              .bold)), // Beschreibung in weiß
                                  const SizedBox(height: 8),
                                  Text(clubDescription,
                                      style: TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 20),
                                  Text('Kommentare',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight
                                              .bold)), // Kommentare in weiß
                                  const SizedBox(height: 8),
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
                                      final commentsDocs =
                                          snapshot.data?.docs ?? [];
                                      if (commentsDocs.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.only(left: 0.0),
                                          child: Text("Keine Kommentare",
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                        );
                                      }
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            commentsDocs.map((commentDoc) {
                                          // Abruf des Timestamps und Formatierung des Datums
                                          final timestamp =
                                              commentDoc['timestamp']
                                                  as Timestamp?;
                                          final formattedDate = timestamp !=
                                                  null
                                              ? DateFormat('dd.MM.yyyy')
                                                  .format(timestamp.toDate())
                                              : 'Unbekanntes Datum';

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0,
                                                top: 4.0,
                                                bottom: 4.0),
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
                                                        commentDoc[
                                                                'userName'] ??
                                                            'Anonym',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white)),
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
                                                            color:
                                                                Colors.white)),
                                                    Expanded(
                                                      child: Text(
                                                          commentDoc['content'],
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                    if (commentDoc['userId'] ==
                                                        currentUser?.uid)
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () {
                                                          deleteComment(
                                                              commentDoc.id);
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                style: TextStyle(
                                    color: Colors.white), // Kommentar in weiß
                                decoration: InputDecoration(
                                  hintText: 'Neuen Kommentar hinzufügen',
                                  hintStyle: TextStyle(
                                      color: Colors
                                          .white70), // Hinweistext in weiß
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send,
                                  color: Colors.white), // Sende-Icon in weiß
                              onPressed: addComment,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Future<double> getAverageRating(String clubId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('ratings')
        .get();
    if (snapshot.docs.isEmpty) {
      return 0.0;
    }
    int total = snapshot.docs
        .map((doc) => doc['rating'] as int)
        .fold(0, (a, b) => a + b);
    return total / snapshot.docs.length;
  }

  Future<int> getRatingCount(String clubId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('ratings')
        .get();
    return snapshot.docs.length;
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
