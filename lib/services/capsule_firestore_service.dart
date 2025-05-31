import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/time_capsule.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CapsuleFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _userId;

  CapsuleFirestoreService(this._userId);

  // Save capsule under the current user
  Future<void> addCapsule(TimeCapsule capsule) async {
    final userCapsulesRef = _db.collection('users').doc(_userId).collection('capsules');
    await userCapsulesRef.add(capsule.toJson());
  }

  // Get all capsules for current user ordered by createdAt
  Future<List<TimeCapsule>> getCapsules() async {
    final userCapsulesRef = _db.collection('users').doc(_userId).collection('capsules');
    final query = await userCapsulesRef.orderBy('createdAt', descending: true).get();
    return query.docs.map((doc) => TimeCapsule.fromJson(doc.data(), doc.id)).toList();
  }
}
