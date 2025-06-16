import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../services/memory_service.dart';
import 'shared_memory_details_page.dart';

class SharedWithYouTab extends StatefulWidget {
  const SharedWithYouTab({super.key});

  @override
  State<SharedWithYouTab> createState() => _SharedWithYouTabState();
}

class _SharedWithYouTabState extends State<SharedWithYouTab> {
  final memoryService = MemoryService();

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text("Please log in to view shared memories."));
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: memoryService.getSharedMemories(currentUserId), // ✅ fixed userId ref
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No shared memories yet."));
          }

          return Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              itemCount: docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.70,
              ),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final memory = doc.data() as Map<String, dynamic>;
                final docId = doc.id;

                final title = memory['title'] ?? 'Untitled';
                final description = memory['description'] ?? '';
                final unlockedAt = (memory['unlockedAt'] as Timestamp).toDate();
                final createdAt = (memory['createdAt'] as Timestamp).toDate();
                final headerImage = (memory['photoUrls'] as List).isNotEmpty
                    ? memory['photoUrls'][0]
                    : null;

                final ownerId = memory['ownerId'];
                print("Owner ID: $ownerId");
                return FutureBuilder<DocumentSnapshot>(
                  future: memoryService.getUserProfile(ownerId),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

                    final profilePic = userData?['profile_picture'] ??
                        'https://www.gravatar.com/avatar/placeholder?d=mp';
                    final username = userData?['username'] ?? 'Unknown';

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SharedMemoryDetailPage(
                            memoryId: docId,
                            memoryData: memory,
                          ),
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 👤 User Info Bar
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(profilePic),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          username,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 📸 Header Image
                                ClipRRect(
                                  // borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: headerImage != null
                                      ? Image.network(
                                          headerImage,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          "assets/images/default_image.png",
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                        ),
                                ),

                                // 📝 Flexible text container
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Text(
                                        //   description,
                                        //   maxLines: 2,
                                        //   overflow: TextOverflow.ellipsis,
                                        //   style: const TextStyle(fontSize: 12),
                                        // ),
                                        const Spacer(),
                                        Text(
                                          "Unlocked: ${DateFormat('dd/MM/yyyy').format(unlockedAt)}",
                                          style: TextStyle(fontSize: 10, color: Colors.blue.shade300),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
