import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart'; // FirebaseService importieren

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
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _editDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchClubData();
  }

  Future<void> fetchClubData() async {
    User? user = _auth.currentUser;
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

  Future<int?> getUserRating(String clubId) async {
    User? user = _auth.currentUser;
    if (user == null) return null;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('ratings')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }
    return snapshot.docs.first['rating'] as int?;
  }

  void saveOrUpdateRating(String clubId, int rating) async {
    User? user = _auth.currentUser;
    if (user == null) return;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('ratings')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('club')
          .doc(clubId)
          .collection('ratings')
          .add({
        'rating': rating,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      DocumentReference ratingDoc = snapshot.docs.first.reference;
      await ratingDoc.update({
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    setState(() {});
    await fetchClubData();
    setState(() {});
  }

  Future<void> addDescription() async {
    User? user = _auth.currentUser;
    if (user == null ||
        clubId == null ||
        _descriptionController.text.trim().isEmpty) {
      print(
          "Cannot add description: user, clubId, or description content is null/empty");
      return;
    }

    print("Adding description: ${_descriptionController.text.trim()}");

    await FirebaseFirestore.instance.collection('club').doc(clubId).set({
      'description': _descriptionController.text.trim(),
    }, SetOptions(merge: true));

    print("Description added successfully.");

    _descriptionController.clear();
    setState(() {});
  }

  Future<void> deleteDescription() async {
    if (clubId == null) return;
    await FirebaseFirestore.instance.collection('club').doc(clubId).update({
      'description':
          FieldValue.delete(), // Löscht das 'description'-Feld aus dem Dokument
    });
    setState(() {});
  }

  Future<void> updateDescription(String newContent) async {
    if (clubId == null || newContent.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('club').doc(clubId).update({
      'description': newContent.trim(),
    });
    setState(() {});
  }

  Future<void> addComment(String descriptionId, String content) async {
    User? user = _auth.currentUser;
    if (user == null || clubId == null || content.trim().isEmpty) {
      print(
          "Cannot add comment: user, clubId, or comment content is null/empty");
      return;
    }

    print("Adding comment: $content");

    await FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('description')
        .doc(descriptionId)
        .collection('comments')
        .add({
      'content': content.trim(),
      'userId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("Comment added successfully.");

    setState(() {});
  }

  Future<void> deleteComment(String descriptionId, String commentId) async {
    if (clubId == null) return;
    await FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('description')
        .doc(descriptionId)
        .collection('comments')
        .doc(commentId)
        .delete();
    setState(() {});
  }

  Future<void> showEditDescriptionDialog(
      String descriptionId, String descriptionContent) async {
    _editDescriptionController =
        TextEditingController(text: descriptionContent);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notiz bearbeiten'),
          content: TextField(
            controller: _editDescriptionController,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Notiz bearbeiten',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Speichern'),
              onPressed: () async {
                await updateDescription(_editDescriptionController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _editDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ihr registrierter Club"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : clubData == null
              ? const Center(child: Text("Kein registrierter Club gefunden."))
              : ListView(
                  children: [
                    ListTile(
                      title: Text(clubData?['name'] ?? 'N/A'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${clubData?['street'] ?? 'N/A'} ${clubData?['house_number'] ?? ''}'),
                          Text(
                              '${clubData?['zip_code'] ?? 'N/A'} ${clubData?['city'] ?? ''}'),
                          FutureBuilder<double>(
                            future: clubId != null
                                ? getAverageRating(clubId!)
                                : Future.value(0.0),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text("Lade Bewertung...");
                              }
                              final averageRating = snapshot.data ?? 0.0;
                              return Row(
                                children: [
                                  Text(averageRating.toStringAsFixed(1)),
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
                                          const Icon(
                                            Icons.star_border,
                                            color: Colors.amber,
                                          ),
                                          ClipRect(
                                            clipper:
                                                StarClipper(fillPercentage),
                                            child: const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                  FutureBuilder<int>(
                                    future: clubId != null
                                        ? getRatingCount(clubId!)
                                        : Future.value(0),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text("...");
                                      }
                                      final ratingCount = snapshot.data ?? 0;
                                      return Text(
                                          ' ($ratingCount Bewertungen)');
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
                              style: Theme.of(context).textTheme.headlineSmall),
                          FutureBuilder<DocumentSnapshot>(
                            future: clubId != null
                                ? FirebaseFirestore.instance
                                    .collection('club')
                                    .doc(clubId)
                                    .get()
                                : Future.value(null),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text("Lade Beschreibung...");
                              }
                              var data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              if (!data.containsKey('description') ||
                                  data['description'].isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _descriptionController,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Neue Beschreibung hinzufügen',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.send),
                                        onPressed: () {
                                          FirebaseService
                                              .addOrUpdateDescription(clubId!,
                                                  _descriptionController.text);
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
                                    Expanded(child: Text(description)),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        _descriptionController.text =
                                            description;
                                        showEditDescriptionDialog(
                                            clubId!, description);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        deleteDescription();
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
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(
                              height: 20), // Space between header and comments
                          StreamBuilder<QuerySnapshot>(
                            stream: clubId != null
                                ? FirebaseService.getComments(clubId!)
                                : null,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text("Lade Kommentare...");
                              }
                              final commentsDocs = snapshot.data?.docs ?? [];
                              if (commentsDocs.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(
                                      "Bisher wurde ihr Club noch nicht kommentiert."),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: commentsDocs.map((commentDoc) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, top: 4.0),
                                    child: Row(
                                      children: [
                                        const Text("- "),
                                        Expanded(
                                            child: Text(commentDoc['content'])),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            FirebaseService.deleteComment(
                                                clubId!, commentDoc.id);
                                          },
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
