import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class UserCapsulesTestPage extends StatelessWidget {
  const UserCapsulesTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('You must be logged in to view your capsules.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Capsules View'),
        backgroundColor: Colors.red.shade700,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('capsules')
            .where('ownerId', isEqualTo: userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No capsules found.'));
          }

          final capsules = snapshot.data!.docs;

          return ListView.builder(
            itemCount: capsules.length,
            itemBuilder: (context, index) {
              final capsule = capsules[index];
              final title = capsule['title'] ?? 'Untitled';
              final description = capsule['description'] ?? '';
              final unlockDate = (capsule['unlockDate'] as Timestamp?)?.toDate();
              final imageUrls = List<String>.from(capsule['photoUrls'] ?? []);
              final videoUrls = List<String>.from(capsule['videoUrls'] ?? []);

              final isUnlocked = unlockDate != null && unlockDate.isBefore(DateTime.now());

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      if (unlockDate != null)
                        Text('Unlock Date: ${DateFormat('dd/MM/yyyy').format(unlockDate)}'),
                      const SizedBox(height: 6),
                      Text(description),
                      const SizedBox(height: 12),

                      if (imageUrls.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Images:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imageUrls.length,
                                itemBuilder: (context, i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Image.network(imageUrls[i], fit: BoxFit.cover, width: 150),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 12),

                      if (videoUrls.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Videos:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Column(
                              children: videoUrls.map((url) {
                                return CapsuleVideoPlayer(videoUrl: url);
                              }).toList(),
                            )
                          ],
                        ),

                      const SizedBox(height: 12),

                      if (isUnlocked)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => _convertToMemory(context,capsule),
                            icon: const Icon(Icons.archive),
                            label: const Text("Convert to Memory"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Future<void> _convertToMemory(BuildContext context, QueryDocumentSnapshot capsule) async {
  //   try {
  //     final data = capsule.data() as Map<String, dynamic>;

  //     final unlockDate = (data['unlockDate'] as Timestamp).toDate();
  //     final createdAt = (data['createdAt'] as Timestamp).toDate();
  //     final ownerId = data['ownerId'];

  //     final commonMemoryData = {
  //       'title': data['title'],
  //       'description': data['description'],
  //       'unlockDate': Timestamp.fromDate(unlockDate),
  //       'unlockedAt': Timestamp.fromDate(unlockDate),
  //       'privacy': data['privacy'],
  //       'createdAt': Timestamp.fromDate(createdAt),
  //       'photoUrls': List<String>.from(data['photoUrls'] ?? []),
  //       'videoUrls': List<String>.from(data['videoUrls'] ?? []),
  //       'audioUrls': List<String>.from(data['audioUrls'] ?? []),
  //       'fileUrls': List<String>.from(data['fileUrls'] ?? []),
  //       'visibleTo': [], // optional: could be ignored in memory
  //     };

  //     final memoryCollection = FirebaseFirestore.instance.collection('memories');

  //     // 🔵 Create memory for owner
  //     await memoryCollection.add({
  //       ...commonMemoryData,
  //       'ownerId': ownerId,
  //       'sourceOwnerId': ownerId,
  //     });

  //     // 🟢 Create memory for each recipient
  //     final visibleTo = List<String>.from(data['visibleTo'] ?? []);
  //     for (final recipientId in visibleTo) {
  //       await memoryCollection.add({
  //         ...commonMemoryData,
  //         'ownerId': recipientId,
  //         'sourceOwnerId': ownerId,
  //       });
  //     }

  //     // 🔴 Delete the original capsule
  //     await FirebaseFirestore.instance.collection('capsules').doc(capsule.id).delete();

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Capsule converted to memory!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     debugPrint('Error converting capsule: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Failed to convert capsule.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }
Future<void> _convertToMemory(BuildContext context, QueryDocumentSnapshot capsule) async {
    try {
      final data = capsule.data() as Map<String, dynamic>;

      final unlockDate = (data['unlockDate'] as Timestamp).toDate();
      final createdAt = (data['createdAt'] as Timestamp).toDate();

      final memoryData = {
        'title': data['title'],
        'description': data['description'],
        'unlockedAt': Timestamp.fromDate(unlockDate), // same as unlockDate
        'unlockDate': Timestamp.fromDate(unlockDate),
        'privacy': data['privacy'],
        'createdAt': Timestamp.fromDate(createdAt),
        'ownerId': data['ownerId'],
        'visibleTo': List<String>.from(data['visibleTo'] ?? []),
        'photoUrls': List<String>.from(data['photoUrls'] ?? []),
        'videoUrls': List<String>.from(data['videoUrls'] ?? []),
        'audioUrls': List<String>.from(data['audioUrls'] ?? []),
        'fileUrls': List<String>.from(data['fileUrls'] ?? []),
      };

      await FirebaseFirestore.instance.collection('memories').add(memoryData);
      await FirebaseFirestore.instance.collection('capsules').doc(capsule.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capsule converted to memory!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      debugPrint('Error converting capsule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to convert capsule.'), backgroundColor: Colors.red),
      );
    }
  }

}

Future<void> addStatusToAllCapsules() async {
  final snapshot = await FirebaseFirestore.instance.collection('capsules').get();

  for (var doc in snapshot.docs) {
    if (!doc.data().containsKey('status')) {
      await doc.reference.update({'status': 'locked'});
    }
  }
}



class CapsuleVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const CapsuleVideoPlayer({super.key, required this.videoUrl});

  @override
  State<CapsuleVideoPlayer> createState() => _CapsuleVideoPlayerState();
}

class _CapsuleVideoPlayerState extends State<CapsuleVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  Future<void> addLikesFieldToMemories() async {
    final firestore = FirebaseFirestore.instance;
    final snapshots = await firestore.collection('memories').get();

    for (final doc in snapshots.docs) {
      final data = doc.data() as Map<String, dynamic>;

      if (!data.containsKey('likedBy')) {
        await doc.reference.update({'likedBy': <String>[]});
      }
    }

    print('All memories updated with likedBy field.');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return Column(
    children: [
      ElevatedButton(
        onPressed: addStatusToAllCapsules,
        child: const Text('Add Statud'),
      ),
      _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : const CircularProgressIndicator(),
      Row(
        children: [
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
          ),
          const Text('Video'),
        ],
      ),
    ],
  );
}
}
