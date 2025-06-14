import '../models/time_capsule.dart';
import '../services/capsule_firestore_service.dart';

class CapsuleRepository {
  final CapsuleFirestoreService _firestoreService;

  CapsuleRepository(this._firestoreService);

  Future<void> createCapsule(TimeCapsule capsule) {
    return _firestoreService.addCapsule(capsule);
  }

  Future<void> updateCapsule(
    String capsuleId, {
    required String privacy,
    required DateTime unlockDate,
    List<String> visibleTo = const [],
  }) {
    return _firestoreService.updateCapsule(
      capsuleId,
      privacy: privacy,
      unlockDate: unlockDate,
      visibleTo: visibleTo,
    );
  }


  Future<void> deleteCapsule(String capsuleId) {
    return _firestoreService.deleteCapsule(capsuleId);
  }

  Future<List<TimeCapsule>> fetchAllCapsules() {
    return _firestoreService.getCapsules();
  }

  Stream<List<TimeCapsule>> streamCapsules() {
    return _firestoreService.getCapsulesStream();
  }

  // Future<List<String>> changePrivacy(){
  //   return _firestoreService.handlePrivacy(privacy: privacy);
  // }
}
