import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/group.dart';
import '../../services/group_service.dart';

class SelectFriendsPage extends StatefulWidget {
  final List<String> initiallySelected;

  const SelectFriendsPage({super.key, this.initiallySelected = const []});

  @override
  State<SelectFriendsPage> createState() => _SelectFriendsPageState();
}

// class _SelectFriendsPageState extends State<SelectFriendsPage> {
//   final GroupService _groupService = GroupService();
//   late Set<String> _selectedIds = {};

//   List<Map<String, String>> _friends = [];
//   List<Group> _groups = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _selectedIds = Set.from(widget.initiallySelected);
//     _loadFriendsAndGroups();
//   }

//   Future<void> _loadFriendsAndGroups() async {
//     try {
//       final currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) return;

//       final firestore = FirebaseFirestore.instance;

//       // Get all accepted friend relationships
//       final asOwner = await firestore
//           .collection('friendList')
//           .where('ownerId', isEqualTo: currentUser.uid)
//           .where('status', isEqualTo: 'accepted')
//           .get();

//       final asFriend = await firestore
//           .collection('friendList')
//           .where('friendId', isEqualTo: currentUser.uid)
//           .where('status', isEqualTo: 'accepted')
//           .get();

//       // Collect unique friend UIDs
//       final friendIds = <String>{};

//       for (var doc in asOwner.docs) {
//         friendIds.add(doc['friendId'] as String);
//       }
//       for (var doc in asFriend.docs) {
//         friendIds.add(doc['ownerId'] as String);
//       }

//       if (friendIds.isNotEmpty) {
//         final userDocs = await firestore
//             .collection('users')
//             .where(FieldPath.documentId, whereIn: friendIds.toList())
//             .get();

//       _friends = userDocs.docs.map((u) {
//         final data = u.data();
//         return {
//           'uid': u.id,
//           'username': (data['username'] ?? 'No Name') as String,
//         };
//       }).toList();

//       }

//       // Get groups created or joined by user
//       _groups = await _groupService.getMyGroups();

//     } catch (e) {
//       debugPrint('Error loading friends/groups: $e');
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   void _toggleUserSelection(String uid, bool isSelected) {
//     setState(() {
//       if (isSelected) {
//         _selectedIds.add(uid);
//       } else {
//         _selectedIds.remove(uid);
//       }
//     });
//   }

//   void _toggleGroupSelection(List<String> memberIds, bool isSelected) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     final memberIdsWithoutCurrentUser = memberIds.where((id) => id != currentUser.uid);

//     setState(() {
//       if (isSelected) {
//         _selectedIds.addAll(memberIdsWithoutCurrentUser);
//       } else {
//         _selectedIds.removeAll(memberIdsWithoutCurrentUser);
//       }
//     });
//   }

//   // void _toggleGroupSelection(List<String> memberIds, bool isSelected) {
//   //   setState(() {
//   //     if (isSelected) {
//   //       _selectedIds.addAll(memberIds);
//   //     } else {
//   //       _selectedIds.removeAll(memberIds);
//   //     }
//   //   });
//   // }

//   void _submitSelection() {
//     Navigator.pop(context, _selectedIds.toList());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Select Friends or Groups")),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                   child: Text("Friends", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 ),
//                 ..._friends.map((friend) {
//                   final uid = friend['uid']!;
//                   final name = friend['username']!;
//                   return CheckboxListTile(
//                     value: _selectedIds.contains(uid),
//                     title: Text(name),
//                     onChanged: (checked) => _toggleUserSelection(uid, checked!),
//                   );
//                 }),

//                 const Divider(height: 24),

//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                   child: Text("Groups", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 ),
//                 ..._groups.map((group) {
//                   final isSelected = group.memberIds.every((id) => _selectedIds.contains(id));
//                   return CheckboxListTile(
//                     value: isSelected,
//                     title: Text(group.name),
//                     subtitle: Text("Includes ${group.memberIds.length} member(s)"),
//                     onChanged: (checked) => _toggleGroupSelection(group.memberIds, checked!),
//                   );
//                 }),
//               ],
//             ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _submitSelection,
//         label: const Text("Done"),
//         icon: const Icon(Icons.check),
//       ),
//     );
//   }
// }

class _SelectFriendsPageState extends State<SelectFriendsPage> {
  final GroupService _groupService = GroupService();
  late Set<String> _selectedIds;
  List<Map<String, String>> _friends = [];
  List<Map<String, String>> _filteredFriends = [];
  List<Group> _groups = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initiallySelected);
    _loadFriendsAndGroups();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredFriends = _friends.where((friend) {
        return friend['username']!.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendsAndGroups() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final firestore = FirebaseFirestore.instance;

      final asOwner = await firestore
          .collection('friendList')
          .where('ownerId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'accepted')
          .get();

      final asFriend = await firestore
          .collection('friendList')
          .where('friendId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'accepted')
          .get();

      final friendIds = <String>{};
      for (var doc in asOwner.docs) {
        friendIds.add(doc['friendId'] as String);
      }
      for (var doc in asFriend.docs) {
        friendIds.add(doc['ownerId'] as String);
      }

      if (friendIds.isNotEmpty) {
        final userDocs = await firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: friendIds.toList())
            .get();

        _friends = userDocs.docs.map((u) {
          final data = u.data();
          return {
            'uid': u.id,
            'username': (data['username'] ?? 'No Name') as String,
          };
        }).toList();
        _filteredFriends = List.from(_friends); // Initially same
      }

      _groups = await _groupService.getMyGroups();
    } catch (e) {
      debugPrint('Error loading friends/groups: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleUserSelection(String uid, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedIds.add(uid);
      } else {
        _selectedIds.remove(uid);
      }
    });
  }

  void _toggleGroupSelection(List<String> memberIds, bool isSelected) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final memberIdsWithoutCurrentUser = memberIds.where((id) => id != currentUser.uid);

    setState(() {
      if (isSelected) {
        _selectedIds.addAll(memberIdsWithoutCurrentUser);
      } else {
        for (var id in memberIdsWithoutCurrentUser) {
          _selectedIds.remove(id);
        }
      }
    });
  }

  void _submitSelection() {
    Navigator.pop(context, _selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Friends or Groups")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search friends...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: Text("Friends", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      ..._filteredFriends.map((friend) {
                        final uid = friend['uid']!;
                        final name = friend['username']!;
                        return CheckboxListTile(
                          value: _selectedIds.contains(uid),
                          title: Text(name),
                          onChanged: (checked) => _toggleUserSelection(uid, checked!),
                        );
                      }),

                      const Divider(height: 24),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: Text("Groups", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      ..._groups.map((group) {
                        final memberIdsWithoutCurrentUser = group.memberIds.where(
                          (id) => id != FirebaseAuth.instance.currentUser?.uid,
                        );

                        final isSelected = memberIdsWithoutCurrentUser.every((id) => _selectedIds.contains(id));
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(group.name),
                          subtitle: Text("Includes ${group.memberIds.length} member(s)"),
                          onChanged: (checked) => _toggleGroupSelection(group.memberIds, checked!),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitSelection,
        label: const Text("Done"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
