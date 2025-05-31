import '../models/time_capsule.dart';
import '../services/capsule_firestore_service.dart';

class CapsuleRepository {
  final CapsuleFirestoreService _firestoreService;

  CapsuleRepository(this._firestoreService);

  Future<void> createCapsule(TimeCapsule capsule) {
    return _firestoreService.addCapsule(capsule);
  }

  Future<List<TimeCapsule>> fetchAllCapsules() {
    return _firestoreService.getCapsules();
  }
}
