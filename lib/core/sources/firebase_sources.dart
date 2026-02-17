import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseAuth get instance => _firebaseAuth;
}

class FirebaseFirestoreSource {
  final FirebaseFirestore _firebaseStore = FirebaseFirestore.instance;

  FirebaseFirestore get instance => _firebaseStore;
}
