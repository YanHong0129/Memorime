import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/group_service.dart';
import '../../models/group.dart';
import '../group/create_group.dart';
import '../friends/friends_main_page.dart';

class GroupMainPage extends StatefulWidget {
  const GroupMainPage({super.key});

  @override
  State<GroupMainPage> createState() => _GroupMainPageState();
}

class _GroupMainPageState extends State<GroupMainPage> {
  final GroupService _groupService = GroupService();
  late Future<List<Group>> _groupFuture;
  List<Group> _allGroups = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    _groupFuture = _groupService.getMyGroups();
    _groupFuture.then((groups) {
      setState(() {
        _allGroups = groups;
      });
    });
  }

  Future<bool> _showAddMemberDialog(
    BuildContext context,
    String groupId,
    List<String> currentMembers,
  ) async {
    final _firestore = FirebaseFirestore.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final Map<String, String> friends = {};

    final friendsSnap =
        await _firestore
            .collection('friendList')
            .where('status', isEqualTo: 'accepted')
            .where('ownerId', isEqualTo: uid)
            .get();

    final friendIds =
        friendsSnap.docs.map((d) => d['friendId'] as String).toList();
    final newFriendIds =
        friendIds.where((id) => !currentMembers.contains(id)).toList();

    if (newFriendIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No more friends to add')));
      return false;
    }

    final usersSnap =
        await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: newFriendIds)
            .get();

    for (var doc in usersSnap.docs) {
      friends[doc.id] = doc['username'] ?? 'No Name';
    }

    final Set<String> selectedFriendIds = {};

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 16,
            right: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add Members',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...friends.entries.map((entry) {
                    return CheckboxListTile(
                      value: selectedFriendIds.contains(entry.key),
                      title: Text(entry.value),
                      onChanged: (selected) {
                        setModalState(() {
                          if (selected == true) {
                            selectedFriendIds.add(entry.key);
                          } else {
                            selectedFriendIds.remove(entry.key);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final groupService = GroupService();
                      for (var uid in selectedFriendIds) {
                        await groupService.addMemberToGroup(groupId, uid);
                      }
                      Navigator.pop(context, true); // ✅ Return true
                    },
                    child: const Text('Add Selected Members'),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        );
      },
    );

    return result == true;
  }

  void _showGroupDetailCard(Group group, Map<String, String> memberNames) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = group.createdBy == currentUserId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                group.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: group.memberIds.length,
                itemBuilder: (context, index) {
                  final id = group.memberIds[index];
                  final name = memberNames[id] ?? 'Unknown';
                  final isTargetMemberOwner = id == group.createdBy;

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Row(
                      children: [
                        Text(name),
                        if (isTargetMemberOwner)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Owner",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing:
                        isOwner && !isTargetMemberOwner
                            ? IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                final confirmed = await _showConfirmationDialog(
                                  context,
                                  'Remove Member',
                                  'Are you sure you want to remove this member?',
                                );

                                if (confirmed == true) {
                                  await _groupService.removeMemberFromGroup(
                                    group.id,
                                    id,
                                  );
                                  Navigator.pop(context);
                                  _loadGroups();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Removed member successfully',
                                      ),
                                    ),
                                  );
                                }
                              },
                            )
                            : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              if (isOwner)
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await _showAddMemberDialog(
                        context,
                        group.id,
                        group.memberIds,
                      );
                      if (result == true) {
                        Navigator.pop(context);
                        _loadGroups();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added members successfully'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Member"),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showEditGroupNameDialog(
    BuildContext context,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);

    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Group Name'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter new group name',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FriendsMainPage()),
                );
              },
              child: const Text(
                'Friends',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            const Text('|', style: TextStyle(fontSize: 20, color: Colors.grey)),
            const SizedBox(width: 8),
            const Text(
              'Groups',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Group>>(
        future: _groupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading groups"));
          }

          final groups = snapshot.data ?? [];
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.groups, size: 125, color: Colors.grey),
                  // const SizedBox(height: 20),
                  const Text(
                    "No groups created yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.group_add, color: Colors.white),
                    label: const Text("Create Group", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateGroupPage(),
                        ),
                      );
                      _loadGroups(); // Reload after creating group
                    },
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<Map<String, String>>(
            future: _groupService.getUserNamesByIds(
              groups.expand((g) => g.memberIds).toSet().toList(),
            ),
            builder: (context, nameSnapshot) {
              if (nameSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (nameSnapshot.hasError) {
                return const Center(child: Text("Error loading member names"));
              }

              final namesMap = nameSnapshot.data ?? {};
              final filteredGroups =
                  _allGroups
                      .where(
                        (g) => g.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Groups',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.group_add, color: Colors.white),
                    ),
                    title: const Text("Create Group"),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateGroupPage(),
                        ),
                      );
                      _loadGroups();
                    },
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredGroups.length,
                      itemBuilder: (context, index) {
                        final group = filteredGroups[index];
                        final members = group.memberIds
                            .map((id) => namesMap[id] ?? id)
                            .join(', ');

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.group, color: Colors.white),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  group.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) async {
                                  final currentUserId =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  final isOwner =
                                      group.createdBy == currentUserId;

                                  if (!isOwner) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'You are not the group owner',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (value == 'edit') {
                                    final newName =
                                        await _showEditGroupNameDialog(
                                          context,
                                          group.name,
                                        );
                                    if (newName != null && newName.isNotEmpty) {
                                      await _groupService.editGroupName(
                                        group.id,
                                        newName,
                                      );
                                      _loadGroups(); // Refresh list
                                    }
                                  } else if (value == 'delete') {
                                    final confirmed = await _showConfirmationDialog(
                                      context,
                                      'Delete Group',
                                      'Are you sure you want to delete this group?',
                                    );
                                    if (confirmed == true) {
                                      await _groupService.deleteMyGroup(
                                        group.id,
                                      );
                                      _loadGroups();
                                    }
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Colors.black54,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Edit Group Name'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Delete Group',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Created at ${DateFormat('yyyy-MM-dd').format(group.createdAt)}\nMembers: ${group.memberIds.length}',
                          ),
                          onTap: () => _showGroupDetailCard(group, namesMap),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
