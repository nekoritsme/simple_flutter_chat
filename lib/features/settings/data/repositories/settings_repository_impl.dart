import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_either/src/dart_either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_flutter_chat/core/logger.dart';

import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FirebaseStorage _firebaseStorage;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;

  SettingsRepositoryImpl({
    required FirebaseStorage firebaseStorage,
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseStorage = firebaseStorage,
       _firebaseAuth = firebaseAuth,
       _firebaseFirestore = firebaseFirestore;

  @override
  Future<Either<String, String>> pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 200,
      );

      if (pickedImage == null) {
        return Left("No image selected");
      }

      final storageRef = _firebaseStorage
          .ref()
          .child("user_profile_pictures")
          .child("${_firebaseAuth.currentUser!.uid}.jpg");

      await storageRef.putFile(File(pickedImage.path));
      final downloadUrl = await storageRef.getDownloadURL();

      _firebaseFirestore
          .collection("users")
          .doc(_firebaseAuth.currentUser!.uid)
          .update({"profileUrl": downloadUrl});

      return Right("Image uploaded");
    } catch (err, stack) {
      talker.error(err, stack);
      return Left("Something went wrong with image uploading");
    }
  }
}
