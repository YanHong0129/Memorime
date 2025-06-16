import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';

class GroupRepository {
  final _groupRef = FirebaseFirestore.instance.collection('groups');

  Future<void> createGroup(Group group) async {
    await _groupRef.add(group.toJson());
  }

  Future<List<Group>> getUserGroups(String userId) async {
    final snapshot = await _groupRef
        .where('memberIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Group.fromJson(doc.data(), doc.id)).toList();
  }

  Future<void> addMember(String groupId, String userId) async {
    await _groupRef.doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeMember(String groupId, String userId) async {
    await _groupRef.doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> deleteGroup(String groupId) async {
    await _groupRef.doc(groupId).delete();
  }
}
