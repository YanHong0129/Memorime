import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

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
            // .orderBy('createdAt', descending: true)
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

                      // Show Images
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

                      // Show Videos (thumbnails with tap to play)
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
        setState(() {}); // Refresh
      });
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
        _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
        Row(
          children: [
            IconButton(
              icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
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
