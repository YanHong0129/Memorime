import 'package:cloud_firestore/cloud_firestore.dart';

class TimeCapsule {
  final String id;
  final String title;
  final String description;
  final DateTime unlockDate;
  final String privacy;
  final DateTime createdAt;
  final List<String> photoUrls;
  final List<String> videoUrls;
  final List<String> audioUrls;
  final List<String> fileUrls;

  TimeCapsule({
    required this.id,
    required this.title,
    required this.description,
    required this.unlockDate,
    required this.privacy,
    required this.createdAt,
    this.photoUrls = const [],
    this.videoUrls = const [],
    this.audioUrls = const [],
    this.fileUrls = const [],
  });

  factory TimeCapsule.fromJson(Map<String, dynamic> json, String docId) {
    print("📥 Parsed unlockDate: ${json['unlockDate']} (${json['unlockDate'].runtimeType})");

    return TimeCapsule(
      id: docId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      unlockDate: (json['unlockDate'] as Timestamp).toDate(),
      privacy: json['privacy'] ?? 'Private',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      videoUrls: List<String>.from(json['videoUrls'] ?? []),
      audioUrls: List<String>.from(json['audioUrls'] ?? []),
      fileUrls: List<String>.from(json['fileUrls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'unlockDate': unlockDate != null ? Timestamp.fromDate(unlockDate) : null,
      'privacy': privacy,
      'createdAt': FieldValue.serverTimestamp(),
      'photoUrls': photoUrls,
      'videoUrls': videoUrls,
      'audioUrls': audioUrls,
      'fileUrls': fileUrls,
    };
  }
}
