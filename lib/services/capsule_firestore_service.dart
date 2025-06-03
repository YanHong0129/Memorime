import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/time_capsule.dart';
import 'package:firebase_auth/firebase_auth.dart';

// class CapsuleFirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final String _userId;

//   CapsuleFirestoreService(this._userId);

//   // Save capsule under the current user
//   Future<void> addCapsule(TimeCapsule capsule) async {
//   await _db.collection('capsules').add({
//     ...capsule.toJson(),
//     'ownerId': _userId,
//     'createdAt': Timestamp.fromDate(DateTime.now()), // ✅ avoid FieldValue.serverTimestamp()
//   });
// }

//   // Get all capsules for current user ordered by createdAt
//   Future<List<TimeCapsule>> getCapsules() async {
//   final query = await _db
//       .collection('capsules')
//       .where('ownerId', isEqualTo: _userId)
//       .orderBy('createdAt', descending: true)
//       .get();

//   return query.docs
//       .map((doc) => TimeCapsule.fromJson(doc.data(), doc.id))
//       .toList();
// }


//   Stream<List<TimeCapsule>> getCapsulesStream() {
//   final userCapsulesRef = _db
//       .collection('capsules')
//       .where('ownerId', isEqualTo: _userId)
//       .orderBy('createdAt', descending: true);
//   return userCapsulesRef.snapshots().map((snapshot) => 
//     snapshot.docs.map((doc) {
//             return TimeCapsule.fromJson(doc.data(), doc.id);
//           }).toList());
// }

// }

class CapsuleFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _userId;

  CapsuleFirestoreService(this._userId);

  Future<void> addCapsule(TimeCapsule capsule) async {
    await _db.collection('capsules').add({
      ...capsule.toJson(),
      'ownerId': _userId,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> updateCapsule(String capsuleId, {
    required String privacy,
    required DateTime unlockDate,
  }) async {
    await _db.collection('capsules').doc(capsuleId).update({
      'privacy': privacy,
      'unlockDate': Timestamp.fromDate(unlockDate),
    });
  }

  Future<void> deleteCapsule(String capsuleId) async {
    await _db.collection('capsules').doc(capsuleId).delete();
  }

  Future<List<TimeCapsule>> getCapsules() async {
    final query = await _db
        .collection('capsules')
        .where('ownerId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((doc) => TimeCapsule.fromJson(doc.data(), doc.id))
        .toList();
  }

  Stream<List<TimeCapsule>> getCapsulesStream() {
    final userCapsulesRef = _db
        .collection('capsules')
        .where('ownerId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true);
    return userCapsulesRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) {
          return TimeCapsule.fromJson(doc.data(), doc.id);
        }).toList());
  }
}