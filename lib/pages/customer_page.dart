import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomerPage(),
    );
  }
}

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveRating(String clubId, int rating) async {
    await _firestore.collection('club').doc(clubId).collection('ratings').add({
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<double> getAverageRating(String clubId) async {
    QuerySnapshot snapshot = await _firestore
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verkäufer"),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('club').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Keine Clubs gefunden."));
          }

          final clubs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              return FutureBuilder<double>(
                future: getAverageRating(club.id),
                builder: (context, avgRatingSnapshot) {
                  if (avgRatingSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final avgRating = avgRatingSnapshot.data ?? 0.0;
                  return ListTile(
                    title: Text(club['name'] ?? 'N/A'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${club['street'] ?? 'N/A'} ${club['house_number'] ?? ''}'),
                        Text(
                            '${club['zip_code'] ?? 'N/A'} ${club['city'] ?? ''}'),
                        Row(
                          children: [
                            Text('${avgRating.toStringAsFixed(1)}'),
                            SizedBox(width: 8),
                            Row(
                              children: List.generate(5, (index) {
                                double starRating = index + 1;
                                double fillPercentage = 0.0;

                                double remainder = avgRating - (starRating - 1);
                                if (remainder >= 0.2 && remainder <= 0.4) {
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
                                    Icon(
                                      Icons.star_border,
                                      color: Colors.amber,
                                    ),
                                    ClipRect(
                                      clipper: StarClipper(fillPercentage),
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Bewertung: '),
                            for (int i = 1; i <= 5; i++)
                              IconButton(
                                icon: const Icon(Icons.star_border),
                                onPressed: () {
                                  saveRating(club.id, i);
                                  setState(
                                      () {}); // Aktualisiere das UI nach dem Speichern der Bewertung
                                },
                              )
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      // Hier könntest du eine Detailseite aufrufen oder weitere Aktionen durchführen
                    },
                  );
                },
              );
            },
          );
        },
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
