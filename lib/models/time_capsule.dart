class TimeCapsule {
  final String title;
  final String description;
  final DateTime unlockDate;
  final String privacy;
  final List<String> photoPaths;
  final List<String> videoPaths;
  final List<String> audioPaths;
  final List<String> filePaths;

  TimeCapsule({
    required this.title,
    required this.description,
    required this.unlockDate,
    required this.privacy,
    required this.photoPaths,
    required this.videoPaths,
    required this.audioPaths,
    required this.filePaths,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'unlockDate': unlockDate.toIso8601String(),
        'privacy': privacy,
        'photoPaths': photoPaths,
        'videoPaths': videoPaths,
        'audioPaths': audioPaths,
        'filePaths': filePaths,
      };
}
