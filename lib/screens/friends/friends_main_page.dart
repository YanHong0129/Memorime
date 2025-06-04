// filepath: c:\FlutterDev\Memorime\TechTribe_MobileApp_Project\lib\admin_home.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsMainPage extends StatefulWidget {
  const FriendsMainPage({super.key});

  @override
  State<FriendsMainPage> createState() => _FriendsMainPageState();
}

class _FriendsMainPageState extends State<FriendsMainPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  List<Map<String, String>> mockFriendRequests = [
    {
      "username": "Lim Ming Ze",
      "profile_picture": "https://randomuser.me/api/portraits/men/11.jpg",
      "uid": "mockuid1",
    },
    {
      "username": "Oh Kai Xuan",
      "profile_picture": "https://randomuser.me/api/portraits/men/12.jpg",
      "uid": "mockuid2",
    },
    {
      "username": "Lebron James",
      "profile_picture": "https://randomuser.me/api/portraits/men/13.jpg",
      "uid": "mockuid3",
    },
  ];

  List<Map<String, String>> mockFriendList = [
    {
      "username": "Michael Jordan",
      "profile_picture": "https://randomuser.me/api/portraits/men/21.jpg",
      "uid": "mockuid4",
    },
    {
      "username": "Stephen Curry",
      "profile_picture": "https://randomuser.me/api/portraits/men/22.jpg",
      "uid": "mockuid5",
    },
    {
      "username": "Luka Doncic",
      "profile_picture": "https://randomuser.me/api/portraits/men/23.jpg",
      "uid": "mockuid6",
    },
  ];

  // Fetch friend requests sent to the current user
  Future<List<Map<String, dynamic>>> fetchFriendRequests() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('friend_requests')
            .get();

    List<Map<String, dynamic>> requests = [];
    for (var doc in querySnapshot.docs) {
      final fromUid = doc.data()['from'];
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(fromUid)
              .get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        userData['uid'] = fromUid;
        requests.add(userData);
      }
    }
    return requests;
  }

  // Fetch all users except the current user
  Future<List<Map<String, dynamic>>> fetchRecommendedFriends() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, isNotEqualTo: currentUser.uid)
            .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  // Accept a friend request
  Future<void> acceptFriendRequest(String fromUid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Add each other as friends
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
          'friends': FieldValue.arrayUnion([fromUid]),
        });
    await FirebaseFirestore.instance.collection('users').doc(fromUid).update({
      'friends': FieldValue.arrayUnion([currentUser.uid]),
    });

    // Remove the friend request
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('friend_requests')
        .doc(fromUid)
        .delete();
    setState(() {});
  }

  // Delete a friend request
  Future<void> deleteFriendRequest(String fromUid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('friend_requests')
        .doc(fromUid)
        .delete();
    setState(() {});
  }

  // Send a friend request
  Future<void> sendFriendRequest(String toUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final requestRef = FirebaseFirestore.instance
        .collection('users')
        .doc(toUserId)
        .collection('friend_requests')
        .doc(currentUser.uid);

    await requestRef.set({
      'from': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Friend request sent!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Friend Requests Section
            const Text(
              'Requests',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Column(
              children:
                  mockFriendRequests
                      .where(
                        (f) => (f["username"] ?? "").toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ),
                      )
                      .map(
                        (friend) => ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              friend["profile_picture"] ??
                                  'https://via.placeholder.com/150',
                            ),
                          ),
                          title: Text(friend["username"] ?? 'No Name'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Accept friend logic (mock)
                                  setState(() {
                                    mockFriendRequests.remove(friend);
                                    mockFriendList.add(friend);
                                  });
                                },
                                child: Text('Confirm'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                onPressed: () {
                                  // Delete friend logic (mock)
                                  setState(() {
                                    mockFriendRequests.remove(friend);
                                  });
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            // Recommended Section
            const Text(
              'Recommended',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchRecommendedFriends(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No recommended friends found.');
                }
                final recommended = snapshot.data!;
                final filtered = recommended.where(
                  (f) => (f["username"] ?? "").toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
                );
                return Column(
                  children:
                      filtered
                          .map(
                            (friend) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  friend["profile_picture"] != null
                                      ? 'https://your-storage-url/${friend["profile_picture"]}'
                                      : 'https://via.placeholder.com/150',
                                ),
                              ),
                              title: Text(friend["username"] ?? 'No Name'),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text('Send Friend Request'),
                                          content: Text(
                                            'Are you sure you want to send a friend request to ${friend["username"]}?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              child: Text('Send'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirm == true) {
                                    await sendFriendRequest(friend['uid']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Friend request sent!'),
                                      ),
                                    );
                                  }
                                },
                                child: Text('Connect'),
                              ),
                            ),
                          )
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            // Friend List Section
            const Text(
              'Friend List',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Column(
              children:
                  mockFriendList
                      .where(
                        (f) => (f["username"] ?? "").toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ),
                      )
                      .map(
                        (friend) => ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              friend["profile_picture"] ??
                                  'https://via.placeholder.com/150',
                            ),
                          ),
                          title: Text(friend["username"] ?? 'No Name'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.grey),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text('Delete Friend'),
                                      content: Text(
                                        'Are you sure you want to delete \\${friend["username"]} from your friend list?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                setState(() {
                                  mockFriendList.remove(friend);
                                });
                              }
                            },
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
