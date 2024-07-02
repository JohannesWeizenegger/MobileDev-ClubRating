import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'osm_service.dart';
import 'club_detail_page.dart';
import 'home_page.dart'; // Importiere die HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  late String userId;
  late List<Map<String, dynamic>> clubs = [];
  bool isLoading = true;

  // Suchfelder
  final TextEditingController _searchNameController = TextEditingController();
  String? _locationQuery;
  double? _maxDistance;

  @override
  void initState() {
    super.initState();
    fetchAllClubData();
    _loadSavedLocation();
    currentUser = _auth.currentUser;
  }

  Future<void> saveOrUpdateRating(String clubId, int rating) async {
    QuerySnapshot snapshot = await _firestore
        .collection('club')
        .doc(clubId)
        .collection('ratings')
        .where('userId', isEqualTo: currentUser?.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      await _firestore
          .collection('club')
          .doc(clubId)
          .collection('ratings')
          .add({
        'rating': rating,
        'userId': currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      DocumentReference ratingDoc = snapshot.docs.first.reference;
      await ratingDoc.update({
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Aktualisieren die Liste Club-Daten hier
    setState(() {});
    await fetchAllClubData();
    setState(() {});
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
        .where('userId', isEqualTo: currentUser?.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }
    return snapshot.docs.first['rating'] as int?;
  }

  Future<void> fetchAllClubData() async {
    QuerySnapshot clubSnapshot = await _firestore.collection('club').get();
    List<Map<String, dynamic>> fetchedClubs = [];
    for (var club in clubSnapshot.docs) {
      var clubData = club.data() as Map<String, dynamic>?;
      if (clubData == null) continue;

      var avgRating = await getAverageRating(club.id);
      var ratingCount = await getRatingCount(club.id);
      var userRating = await getUserRating(club.id);

      fetchedClubs.add({
        'data': clubData,
        'id': club.id,
        'avgRating': avgRating,
        'ratingCount': ratingCount,
        'userRating': userRating,
      });
    }
    setState(() {
      clubs = fetchedClubs;
      isLoading = false;
    });
  }

  Future<void> _loadSavedLocation() async {
    setState(() {
      _locationQuery = null;
      _maxDistance = null;
    });
  }

  Future<void> performSearch() async {
    setState(() {
      isLoading = true;
    });

    String nameQuery = _searchNameController.text.trim().toLowerCase();
    String? locationQuery = _locationQuery;
    double? searchLatitude;
    double? searchLongitude;

    if (locationQuery != null && locationQuery.isNotEmpty) {
      final coordinates =
          await OSMService.getCoordinates("", "", locationQuery, "");
      if (coordinates != null) {
        searchLatitude = coordinates['lat'];
        searchLongitude = coordinates['lon'];
      }
    }

    QuerySnapshot clubSnapshot = await _firestore.collection('club').get();
    List<Map<String, dynamic>> fetchedClubs = [];
    for (var club in clubSnapshot.docs) {
      var clubData = club.data() as Map<String, dynamic>?;
      if (clubData == null) continue;

      var avgRating = await getAverageRating(club.id);
      var ratingCount = await getRatingCount(club.id);
      var userRating = await getUserRating(club.id);

      bool matchesName = nameQuery.isEmpty ||
          (clubData['name'] as String).toLowerCase().contains(nameQuery);
      bool matchesDistance = true;

      if (_maxDistance != null &&
          searchLatitude != null &&
          searchLongitude != null) {
        double clubLatitude = clubData['latitude'];
        double clubLongitude = clubData['longitude'];
        double distance = OSMService.calculateDistance(
            searchLatitude, searchLongitude, clubLatitude, clubLongitude);
        matchesDistance = distance <= _maxDistance!;
      }

      if (matchesName && matchesDistance) {
        fetchedClubs.add({
          'data': clubData,
          'id': club.id,
          'avgRating': avgRating,
          'ratingCount': ratingCount,
          'userRating': userRating,
        });
      }
    }
    setState(() {
      clubs = fetchedClubs;
      isLoading = false;
    });
  }

  Future<void> _openLocationDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationDialog(
        initialLocation: _locationQuery,
        initialRadius: _maxDistance,
      ),
    );

    if (result != null) {
      setState(() {
        _locationQuery = result['location'];
        _maxDistance = result['radius'];
      });

      performSearch();
    }
  }

  void _resetSearch() {
    setState(() {
      _locationQuery = null;
      _maxDistance = null;
      _searchNameController.clear();
    });

    performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900], // AppBar in dunklem Grün
        title: const Text("Canna-Clubs", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => HomePage()), // Hier die HomePage
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.green[900], // Hintergrundfarbe des gesamten Bildschirms
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchNameController,
                        style:
                            TextStyle(color: Colors.white), // Textfarbe in weiß
                        decoration: InputDecoration(
                          labelText: "Clubname",
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onFieldSubmitted: (value) {
                          performSearch();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.place, color: Colors.white),
                      onPressed: _openLocationDialog,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.green[900],
                        backgroundColor: Colors.white, // Primärfarbe des Textes
                      ),
                      onPressed: performSearch,
                      child: const Text("Finden"),
                    ),
                  ],
                ),
              ),
              if (_locationQuery != null && _maxDistance != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Chip(
                    backgroundColor: Colors.white,
                    label: Text(
                        "$_locationQuery (+${_maxDistance!.toInt()} km)",
                        style: TextStyle(color: Colors.green[900])),
                    onDeleted: _resetSearch,
                  ),
                ),
              if (isLoading)
                const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white)) // Ladeindikator in weiß
              else if (clubs.isEmpty)
                const Center(
                  child: Text(
                    "Keine Clubs gefunden.",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white, // Textfarbe in weiß
                    ),
                  ),
                )
              else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    final club = clubs[index];
                    final userRating = club['userRating'];

                    return ListTile(
                      title: Text(club['data']['name'] ?? 'N/A',
                          style:
                              TextStyle(color: Colors.white)), // Titel in weiß
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${club['data']['street'] ?? 'N/A'} ${club['data']['house_number'] ?? ''}',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            '${club['data']['zip_code'] ?? 'N/A'} ${club['data']['city'] ?? ''}',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Row(
                            children: [
                              Text('${club['avgRating'].toStringAsFixed(1)}',
                                  style: TextStyle(color: Colors.white70)),
                              const SizedBox(width: 8),
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
                                        clipper: StarClipper(fillPercentage),
                                        child: const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                              Text(' (${club['ratingCount']} Bewertungen)',
                                  style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: const Text('Bewertung:',
                                      style: TextStyle(color: Colors.white70))),
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
                                  },
                                )
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ClubDetailPage(club: club),
                        ));
                      },
                    );
                  },
                ),
            ],
          ),
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

class LocationDialog extends StatefulWidget {
  final String? initialLocation;
  final double? initialRadius;

  const LocationDialog({this.initialLocation, this.initialRadius});

  @override
  _LocationDialogState createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  final TextEditingController _locationController = TextEditingController();
  double _radius = 10.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _locationController.text = widget.initialLocation!;
    }
    if (widget.initialRadius != null) {
      _radius = widget.initialRadius!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        backgroundColor: Colors.green[900],
        title: const Text("Standort und Entfernung",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _locationController,
              style: TextStyle(color: Colors.white), // Textfarbe in weiß
              decoration: InputDecoration(
                labelText: "PLZ oder Ort",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Entfernung: ${_radius.toInt()} km",
                style: TextStyle(color: Colors.white)), // Textfarbe in weiß
            Slider(
              value: _radius,
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: Colors.white,
              inactiveColor: Colors.white70,
              label: _radius.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _radius = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child:
                const Text("Abbrechen", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.green[900],
              backgroundColor: Colors.white,
            ),
            onPressed: () async {
              String locationName = _locationController.text;
              final valid =
                  await OSMService.validateAddress("", "", locationName, "");
              if (!valid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ungültige Adresse")),
                );
                return;
              }
              if (locationName.isNotEmpty) {
                final place =
                    await OSMService.getPlaceFromCoordinates(locationName);
                locationName = place ?? locationName;
              }
              Navigator.pop(context, {
                'location': locationName,
                'radius': _radius,
              });
            },
            child: const Text("Speichern"),
          ),
        ],
      ),
    );
  }
}
