import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'osm_service.dart'; // Importiere die OSM-Services

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

    if (selectedImage == null) {
      throw Exception('Bitte wählen Sie ein Bild aus');
    }

    final String userId = user.uid;
    final String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference referenceRoot = FirebaseStorage.instance.ref();
    final Reference referenceDirImages = referenceRoot.child('images');
    final Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    await referenceImageToUpload.putFile(selectedImage);
    final String imageUrl = await referenceImageToUpload.getDownloadURL();

    // Prüfen, ob bereits ein Club existiert
    QuerySnapshot clubSnapshot = await FirebaseFirestore.instance
        .collection('club')
        .where('owner_id', isEqualTo: userId)
        .get();

    if (clubSnapshot.docs.isNotEmpty) {
      throw Exception('Ein Club mit diesem Owner existiert bereits');
    }

    // Erhalte die Geokoordinaten
    final coordinates = await OSMService.getCoordinates(
      clubStreet,
      clubHouseNumber,
      clubZipCode,
      clubCity,
    );

    if (coordinates == null) {
      throw Exception('Koordinaten konnten nicht ermittelt werden');
    }

    // Speichere die Daten in der Sammlung newClubRequest
    await FirebaseFirestore.instance
        .collection('newClubRequest')
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

    // Erstelle oder aktualisiere den Owner-Eintrag
    await FirebaseFirestore.instance.collection('owner').doc(userId).set({
      'name': ownerName,
      'street': ownerStreet,
      'house_number': ownerHouseNumber,
      'zip_code': ownerZipCode,
      'city': ownerCity,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Erstelle einen neuen Club-Eintrag mit einer eindeutigen ID und füge die Koordinaten hinzu
    DocumentReference clubRef = FirebaseFirestore.instance.collection('club').doc();
    await clubRef.set({
      'name': clubName,
      'street': clubStreet,
      'house_number': clubHouseNumber,
      'zip_code': clubZipCode,
      'city': clubCity,
      'owner_id': userId, // Referenz auf den Owner
      'latitude': coordinates['lat'], // Latitude
      'longitude': coordinates['lon'], // Longitude
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
