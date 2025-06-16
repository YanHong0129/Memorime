import '../models/group.dart';
import '../repository/group_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupService {
  final GroupRepository _groupRepository = GroupRepository();

  // Get current user's ID
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> createGroup(String name, List<String> selectedMemberIds) async {
    final group = Group(
      id: '', // Firestore will auto-generate
      name: name,
      createdBy: currentUserId,
      memberIds: [currentUserId, ...selectedMemberIds],
      createdAt: DateTime.now(),
    );

    await _groupRepository.createGroup(group);
  }

  Future<Map<String, String>> getUserNamesByIds(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIds)
            .get();

    return {
      for (var doc in snapshot.docs) doc.id: doc.data()['username'] ?? 'Unknown',
    };
  }

  Future<List<Group>> getMyGroups() {
    return _groupRepository.getUserGroups(currentUserId);
  }

  Future<void> editGroupName(String groupId, String newName) async {
  await FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .update({'name': newName});
}


  Future<void> addMemberToGroup(String groupId, String userId) {
    return _groupRepository.addMember(groupId, userId);
  }

  Future<void> removeMemberFromGroup(String groupId, String userId) {
    return _groupRepository.removeMember(groupId, userId);
  }

  Future<void> deleteMyGroup(String groupId) {
    return _groupRepository.deleteGroup(groupId);
  }
}
