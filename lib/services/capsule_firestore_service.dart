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

// class CapsuleFirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final String _userId;

//   CapsuleFirestoreService(this._userId);

//   // Create
//   Future<void> addCapsule(TimeCapsule capsule) async {
//     await _db.collection('capsules').add(capsule.toJson());
//   }

//   // Read
//   Future<List<TimeCapsule>> getCapsules() async {
//     final query = await _db
//         .collection('capsules')
//         .where('ownerId', isEqualTo: _userId)
//         .orderBy('createdAt', descending: true)
//         .get();

//     return query.docs
//         .map((doc) => TimeCapsule.fromJson(doc.data(), doc.id))
//         .toList();
//   }

//   // Update specific fields (privacy, unlockDate)
//   Future<void> updateCapsule(String capsuleId, {
//     String? privacy,
//     DateTime? unlockDate,
//   }) async {
//     final Map<String, dynamic> updates = {};
//     if (privacy != null) updates['privacy'] = privacy;
//     if (unlockDate != null) updates['unlockDate'] = unlockDate;

//     if (updates.isNotEmpty) {
//       await _db.collection('capsules').doc(capsuleId).update(updates);
//     }
//   }

//   // Delete
//   Future<void> deleteCapsule(String capsuleId) async {
//     await _db.collection('capsules').doc(capsuleId).delete();
//   }
// }