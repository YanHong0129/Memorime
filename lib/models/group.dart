import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;

  Group({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    this.memberIds = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json, String docId) {
    return Group(
      id: docId,
      name: json['name'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      memberIds: List<String>.from(json['memberIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'memberIds': memberIds,
    };
  }
}
