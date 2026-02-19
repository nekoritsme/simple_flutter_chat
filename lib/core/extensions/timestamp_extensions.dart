import 'package:cloud_firestore/cloud_firestore.dart';

extension TimestampToDateExtension on Timestamp? {
  DateTime? get toDateTime => this?.toDate();
}
