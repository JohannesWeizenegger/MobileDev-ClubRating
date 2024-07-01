import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'osm_service.dart';

class FirebaseService {
  static Future<void> saveClubData({
    required String clubName,
    required String clubStreet,
    required String clubHouseNumber,
    required String clubZipCode,
    required String clubCity,
    required String ownerName,
    required String ownerStreet,
    required String ownerHouseNumber,
    required String ownerZipCode,
    required String ownerCity,
    required File? selectedImage,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User ist nicht eingeloggt');
    }

    final String userId = user.uid;

    // Überprüfen ob der Benutzer bereits einen Club registriert hat
    final QuerySnapshot existingClubs = await FirebaseFirestore.instance
        .collection('club')
        .where('owner_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingClubs.docs.isNotEmpty) {
      throw Exception('Sie haben bereits einen Club registriert.');
    }

    if (selectedImage == null) {
      throw Exception('Bitte wählen Sie ein Bild aus');
    }

    final String uniqueFileName =
        DateTime.now().millisecondsSinceEpoch.toString();
    final Reference referenceRoot = FirebaseStorage.instance.ref();
    final Reference referenceDirImages = referenceRoot.child('images');
    final Reference referenceImageToUpload =
        referenceDirImages.child(uniqueFileName);

    await referenceImageToUpload.putFile(selectedImage);
    final String imageUrl = await referenceImageToUpload.getDownloadURL();

    final coordinates = await OSMService.getCoordinates(
        clubStreet, clubHouseNumber, clubZipCode, clubCity);

    if (coordinates == null) {
      throw Exception('Ungültige Adresse');
    }

    final double latitude = coordinates['lat']!;
    final double longitude = coordinates['lon']!;

    // Speichere die Daten in der Sammlung newClubRequests
    await FirebaseFirestore.instance
        .collection('newClubRequests')
        .doc(userId)
        .set({
      'club_name': clubName,
      'club_street': clubStreet,
      'club_house_number': clubHouseNumber,
      'club_zip_code': clubZipCode,
      'club_city': clubCity,
      'owner_name': ownerName,
      'owner_street': ownerStreet,
      'owner_house_number': ownerHouseNumber,
      'owner_zip_code': ownerZipCode,
      'owner_city': ownerCity,
      'image_url': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Erstelle einen neuen Eintrag in der Sammlung owners und erhalte die Dokument-ID
    DocumentReference ownerRef =
        FirebaseFirestore.instance.collection('owner').doc(userId);
    await ownerRef.set({
      'name': ownerName,
      'street': ownerStreet,
      'house_number': ownerHouseNumber,
      'zip_code': ownerZipCode,
      'city': ownerCity,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Speichere die Daten in der Sammlung clubs mit einer Referenz zum Owner
    await FirebaseFirestore.instance.collection('club').add({
      'name': clubName,
      'street': clubStreet,
      'house_number': clubHouseNumber,
      'zip_code': clubZipCode,
      'city': clubCity,
      'owner_id': userId, // Referenz auf den Owner
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Kommentar hinzufügen
  static Future<void> addComment(String clubId, String commentContent) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User ist nicht eingeloggt');
    }

    final String userName = user.email ?? 'Anonym';

    await FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('comments')
        .add({
      'content': commentContent,
      'userId': user.uid,
      'userName': userName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Kommentare auslesen
  static Stream<QuerySnapshot> getComments(String clubId) {
    return FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getClubDescription(String clubId) {
    return FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('description')
        .snapshots();
  }

  // Kommentar löschen
  static Future<void> deleteComment(String clubId, String commentId) async {
    await FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  static Future<void> updateDescription(
      String newContent, String clubId) async {
    if (newContent.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('club').doc(clubId).update({
      'description': newContent.trim(),
    });
  }

//lösche CLub
  static Future<void> deleteClub(String clubId) async {
    // Lösche alle Unterkollektionen (z.B. comments, ratings)
    final commentsSnapshot = await FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('comments')
        .get();
    for (DocumentSnapshot doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }

    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('club')
        .doc(clubId)
        .collection('ratings')
        .get();
    for (DocumentSnapshot doc in ratingsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Lösche das Club-Dokument
    await FirebaseFirestore.instance.collection('club').doc(clubId).delete();

    final User? user = FirebaseAuth.instance.currentUser;
    // Lösche das Owner und newClubRequest-Dokument
    if (user != null) {
      await FirebaseFirestore.instance.collection('owner').doc(user.uid).delete();
      await FirebaseFirestore.instance.collection('newClubRequests').doc(user.uid).delete();
    }
  }
}
