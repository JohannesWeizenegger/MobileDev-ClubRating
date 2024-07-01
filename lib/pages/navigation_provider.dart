import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState extends ChangeNotifier {
  User? _user;
  int _currentIndex = 0;
  bool _alreadyRegistered = false;

  User? get user => _user;
  int get currentIndex => _currentIndex;
  bool get alreadyRegistered => _alreadyRegistered;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setAlreadyRegistered(bool status) {
    _alreadyRegistered = status;
    notifyListeners();
  }

  void checkAlreadyRegistered() async{
    if (_user != null) {
      final String userId = _user!.uid;
      final QuerySnapshot userClubDocs = await FirebaseFirestore.instance
          .collection('club')
          .where('owner_id', isEqualTo: userId)
          .get();

      setAlreadyRegistered(userClubDocs.docs.isNotEmpty);
    } else {
      setAlreadyRegistered(false);
    }
  }
}
