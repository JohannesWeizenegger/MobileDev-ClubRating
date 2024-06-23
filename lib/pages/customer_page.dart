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

  // Beispieluser-Id, in einer realen Anwendung würde diese aus der Authentifizierung kommen
  final String userId = "exampleUserId";

  Future<void> saveOrUpdateRating(String clubId, int rating) async {
    QuerySnapshot snapshot = await _firestore
        .collection('club')
        .doc(clubId)
        .collection('ratings')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      // Wenn keine Bewertung vorhanden ist, füge eine neue Bewertung hinzu
      await _firestore
          .collection('club')
          .doc(clubId)
          .collection('ratings')
          .add({
        'rating': rating,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Wenn eine Bewertung vorhanden ist, aktualisiere sie
      DocumentReference ratingDoc = snapshot.docs.first.reference;
      await ratingDoc.update({
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
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

  Future<int> getRatingCount(String clubId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('club')
        .doc(clubId)
        .collection('ratings')
        .get();
    return snapshot.docs.length;
  }

  Future<int?> getUserRating(String clubId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('club')
        .doc(clubId)
        .collection('ratings')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }
    return snapshot.docs.first['rating'] as int?;
  }

  Future<List<Map<String, dynamic>>> fetchAllClubData() async {
    QuerySnapshot clubSnapshot = await _firestore.collection('club').get();
    List<Map<String, dynamic>> clubs = [];
    for (var club in clubSnapshot.docs) {
      var avgRating = await getAverageRating(club.id);
      var ratingCount = await getRatingCount(club.id);
      var userRating = await getUserRating(club.id);
      clubs.add({
        'data': club.data(),
        'id': club.id,
        'avgRating': avgRating,
        'ratingCount': ratingCount,
        'userRating': userRating,
      });
    }
    return clubs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verkäufer"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllClubData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Keine Clubs gefunden."));
          }

          final clubs = snapshot.data!;

          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              final userRating = club['userRating'];

              return ListTile(
                title: Text(club['data']['name'] ?? 'N/A'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${club['data']['street'] ?? 'N/A'} ${club['data']['house_number'] ?? ''}'),
                    Text(
                        '${club['data']['zip_code'] ?? 'N/A'} ${club['data']['city'] ?? ''}'),
                    Row(
                      children: [
                        Text('${club['avgRating'].toStringAsFixed(1)}'),
                        SizedBox(width: 8),
                        Row(
                          children: List.generate(5, (index) {
                            double starRating = index + 1;
                            double fillPercentage = 0.0;

                            double remainder =
                                club['avgRating'] - (starRating - 1);
                            if (remainder >= 0.2 && remainder <= 0.4) {
                              fillPercentage = 0.4;
                            } else if (remainder == 0.5) {
                              fillPercentage = 0.5;
                            } else if (remainder >= 0.6 && remainder <= 0.8) {
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
                        Text(' (${club['ratingCount']} Bewertungen)'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Bewertung: '),
                        for (int i = 1; i <= 5; i++)
                          IconButton(
                            icon: Icon(
                              i <= (userRating ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              saveOrUpdateRating(club['id'], i);
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
