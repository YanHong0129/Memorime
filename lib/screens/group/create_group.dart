import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/group_service.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _groupNameController = TextEditingController();
  final _groupService = GroupService();
  final _firestore = FirebaseFirestore.instance;

  Map<String, String> _friends = {}; // uid => username
  Set<String> _selectedFriendIds = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    final friendsSnap = await _firestore
        .collection('friendList')
        .where('status', isEqualTo: 'accepted')
        .where('ownerId', isEqualTo: uid)
        .get();

    final friendIds = friendsSnap.docs.map((d) => d['friendId'] as String).toList();

    if (friendIds.isEmpty) return;

    final usersSnap = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendIds)
        .get();

    final friendsMap = <String, String>{};
    for (var doc in usersSnap.docs) {
      friendsMap[doc.id] = doc['username'] ?? 'No Name';
    }

    setState(() => _friends = friendsMap);
  }

  Future<void> _createGroup() async {
    final name = _groupNameController.text.trim();
    if (name.isEmpty || _selectedFriendIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter group name and select members')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _groupService.createGroup(name, _selectedFriendIds.toList());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Group'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Group Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Members:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _friends.isEmpty
                        ? const Center(child: Text('No friends to add'))
                        : ListView(
                            children: _friends.entries.map((entry) {
                              return CheckboxListTile(
                                value: _selectedFriendIds.contains(entry.key),
                                title: Text(entry.value),
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected == true) {
                                      _selectedFriendIds.add(entry.key);
                                    } else {
                                      _selectedFriendIds.remove(entry.key);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createGroup,
                      child: const Text('Create Group'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
