// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;

// import 'dart:io';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:permission_handler/permission_handler.dart';

// class CreateTimeCapsulePage extends StatefulWidget {
//   const CreateTimeCapsulePage({super.key});

//   @override
//   State<CreateTimeCapsulePage> createState() => _CreateTimeCapsulePageState();
// }

// class _CreateTimeCapsulePageState extends State<CreateTimeCapsulePage> {
//   final TextEditingController _titleController = TextEditingController();
//   final quill.QuillController _quillController = quill.QuillController.basic();
//   bool _showToolbar = true;

//   DateTime? _selectedDate;
//   String _privacy = 'Private';

//   final ImagePicker _picker = ImagePicker();

//   Future<void> insertImage() async {
//     final status = await Permission.photos.request();
//     final storageStatus = await Permission.storage.request();

//     if (status.isGranted || storageStatus.isGranted) {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//       if (image != null) {
//         final imageUrl = image.path; // Use the local path
//         final index = _quillController.selection.baseOffset;

//         _quillController.replaceText(
//           index,
//           0,
//           quill.BlockEmbed.image(imageUrl),
//           TextSelection.collapsed(offset: index + 1),
//         );
//       }
//     } else {
//       debugPrint('Permission denied');
//     }
//   }

//   Future<void> insertVideo() async {
//     final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
//     if (video != null) {
//       final videoUri = File(video.path).uri.toString();
//       final index = _quillController.selection.baseOffset;

//       _quillController.replaceText(
//         index,
//         0,
//         quill.BlockEmbed.video(videoUri),
//         const TextSelection.collapsed(offset: 0),
//       );
//     }
//   }

//   Future<void> insertAudio() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.audio);
//     if (result != null && result.files.single.path != null) {
//       final audioPath = result.files.single.path!;
//       final index = _quillController.selection.baseOffset;

//       _quillController.replaceText(
//         index,
//         0,
//         '\nAudio: $audioPath\n',
//         const TextSelection.collapsed(offset: 0),
//       );
//     }
//   }

//   Future<void> insertFile() async {
//     final result = await FilePicker.platform.pickFiles();
//     if (result != null && result.files.single.path != null) {
//       final filePath = result.files.single.path!;
//       final index = _quillController.selection.baseOffset;

//       _quillController.replaceText(
//         index,
//         0,
//         '\nFile: $filePath\n',
//         const TextSelection.collapsed(offset: 0),
//       );
//     }
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Widget _buildPrivacyOption(String label) {
//     final bool isSelected = _privacy == label;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _privacy = label),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           margin: const EdgeInsets.symmetric(horizontal: 4),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.deepPurple : Colors.transparent,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.deepPurple),
//           ),
//           child: Center(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.deepPurple,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleFormSubmission() {
//     final String title = _titleController.text;
//     final String descriptionJson = _quillController.document.toDelta().toJson().toString();
//     final String? unlockDate = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null;

//     // For demo: print to console (you can replace this with database save or API call)
//     debugPrint('Title: $title');
//     debugPrint('Description: $descriptionJson');
//     debugPrint('Unlock Date: $unlockDate');
//     debugPrint('Privacy: $_privacy');

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Capsule created successfully!')),
//     );

//     Navigator.pop(context); // or navigate to another page
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _quillController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Capsule'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: ListView(
//           children: [
//             const Text('Capsule Title', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 6),
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'Enter capsule title',
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 6),
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade400),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Quill editor (input box) first
//                   SizedBox(
//                     height: 200,
//                     child: quill.QuillEditor.basic(
//                       controller: _quillController,
//                     ),
//                   ),

//                   // Toolbar toggle button
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: IconButton(
//                       icon: Icon(
//                         _showToolbar ? Icons.expand_less : Icons.expand_more,
//                         color: Colors.grey,
//                       ),
//                       tooltip: _showToolbar ? 'Hide Toolbar' : 'Show Toolbar',
//                       onPressed: () {
//                         setState(() {
//                           _showToolbar = !_showToolbar;
//                         });
//                       },
//                     ),
//                   ),

//                   // Conditional toolbar
//                   if (_showToolbar)
//                     quill.QuillSimpleToolbar(controller: _quillController),

//                   // Media buttons row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.image),
//                         onPressed: insertImage,
//                         tooltip: 'Insert Image',
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.videocam),
//                         onPressed: insertVideo,
//                         tooltip: 'Insert Video',
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.music_note),
//                         onPressed: insertAudio,
//                         tooltip: 'Insert Audio',
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.attach_file),
//                         onPressed: insertFile,
//                         tooltip: 'Insert File',
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text('Date Unlock', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 6),
//             GestureDetector(
//               onTap: _pickDate,
//               child: AbsorbPointer(
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: _selectedDate != null
//                         ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
//                         : 'DD/MM/YYYY',
//                     suffixIcon: const Icon(Icons.calendar_today),
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 _buildPrivacyOption('Private'),
//                 _buildPrivacyOption('Public'),
//                 _buildPrivacyOption('Specific'),
//               ],
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _handleFormSubmission,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text(
//                 'Next',
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:intl/intl.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';

// class CreateTimeCapsulePage extends StatefulWidget {
//   const CreateTimeCapsulePage({super.key});

//   @override
//   State<CreateTimeCapsulePage> createState() => _CreateTimeCapsulePageState();
// }

// class _CreateTimeCapsulePageState extends State<CreateTimeCapsulePage> {
//   final TextEditingController _titleController = TextEditingController();
//   final quill.QuillController _quillController = quill.QuillController.basic();
//   bool _showToolbar = false;
//   bool _isLoading = false;
//   bool _showMediaSection = false;


//   DateTime? _selectedDate;
//   String _privacy = 'Private';

//   final ImagePicker _picker = ImagePicker();

//   List<File> _photoFiles = [];
//   List<File> _videoFiles = [];
//   List<File> _audioFiles = [];
//   List<File> _otherFiles = [];

//   Future<void> _addPhoto() async {
//     final status = await Permission.photos.request();
//     final storageStatus = await Permission.storage.request();

//     if (status.isGranted || storageStatus.isGranted) {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//       if (image != null) {
//         setState(() {
//           _photoFiles.add(File(image.path));
//         });
//       }
//     } else {
//       debugPrint('Permission denied');
//     }
//   }

//   Future<void> _addVideo() async {
//     final status = await Permission.photos.request();
//     final storageStatus = await Permission.storage.request();

//     if (status.isGranted || storageStatus.isGranted) {
//       final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
//       if (video != null) {
//         setState(() {
//           _videoFiles.add(File(video.path));
//         });
//       }
//     } else {
//       debugPrint('Permission denied for video');
//     }
//   }

// Future<void> _addAudio() async {
//   if (_isLoading) return;
//   setState(() => _isLoading = true);

//   final granted = await Permission.storage.isGranted || await Permission.manageExternalStorage.isGranted;
//   if (!granted) {
//     final statuses = await [Permission.storage, Permission.manageExternalStorage].request();
//     if (!(statuses[Permission.storage]?.isGranted ?? false) &&
//         !(statuses[Permission.manageExternalStorage]?.isGranted ?? false)) {
//       debugPrint('Permission denied for audio');
//       setState(() => _isLoading = false);
//       return;
//     }
//   }

//   final result = await FilePicker.platform.pickFiles(type: FileType.audio);
//   if (result != null && result.files.single.path != null) {
//     setState(() {
//       _audioFiles.add(File(result.files.single.path!));
//     });
//   }

//   setState(() => _isLoading = false);
// }


// Future<void> _addFile() async {
//   if (_isLoading) return; // Prevent multiple simultaneous calls
//   setState(() => _isLoading = true);

//   if (await Permission.storage.isGranted || await Permission.manageExternalStorage.isGranted) {
//     await _pickAnyFile();
//   } else {
//     final statuses = await [Permission.storage, Permission.manageExternalStorage].request();

//     if (statuses[Permission.storage]!.isGranted || statuses[Permission.manageExternalStorage]!.isGranted) {
//       await _pickAnyFile();
//     } else {
//       debugPrint('Permission denied for file');
//     }
//   }

//   setState(() => _isLoading = false);
// }

//   Future<void> _pickAnyFile() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.any);
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         _otherFiles.add(File(result.files.single.path!));
//       });
//     }
//   }
//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) setState(() => _selectedDate = picked);
//   }

//   Widget _buildSectionCard(String title, IconData icon, List<File> files, VoidCallback onAdd) {
//   return Card(
//     elevation: 3,
//     margin: const EdgeInsets.symmetric(vertical: 10),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     child: Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: Colors.deepPurple),
//               const SizedBox(width: 8),
//               Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//               const Spacer(),
//               IconButton(
//                 onPressed: onAdd,
//                 icon: const Icon(Icons.add_circle_outline, color: Colors.deepPurple),
//               )
//             ],
//           ),
//           if (files.isNotEmpty)
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: files.map((file) {
//                 bool isImage = file.path.endsWith('.jpg') || file.path.endsWith('.jpeg') || file.path.endsWith('.png');
//                 bool isVideo = file.path.endsWith('.mp4') || file.path.endsWith('.mov') || file.path.endsWith('.avi');

//                 return Stack(
//                   children: [
//                     Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.grey.shade200,
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: isImage
//                             ? Image.file(file, fit: BoxFit.cover)
//                             : isVideo
//                                 ? Stack(
//                                     alignment: Alignment.center,
//                                     children: [
//                                       Image.asset(
//                                         'assets/images/video_placeholder.jpg',
//                                         fit: BoxFit.cover,
//                                         width: 100,
//                                         height: 100,
//                                       ),
//                                       const Icon(Icons.play_circle_outline, size: 32, color: Colors.white),
//                                     ],
//                                   )
//                                 : Center(
//                                     child: Text(
//                                       file.path.split('/').last,
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(fontSize: 12),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 0,
//                       right: 0,
//                       child: GestureDetector(
//                         onTap: () => setState(() => files.remove(file)),
//                         child: Container(
//                           padding: const EdgeInsets.all(2),
//                           decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.black54,
//                           ),
//                           child: const Icon(Icons.close, color: Colors.white, size: 18),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             )
//         ],
//       ),
//     ),
//   );
// }

//   void _handleFormSubmission() {
//     final String title = _titleController.text;
//     final String description = _quillController.document.toPlainText();
//     debugPrint('Title: $title');
//     debugPrint('Description: $description');
//     debugPrint('Unlock Date: $_selectedDate');
//     debugPrint('Privacy: $_privacy');

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Capsule created successfully!')),
//     );
//     Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _quillController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: AppBar(
//           title: const Text('Create Capsule', style: TextStyle(color: Colors.white)),
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           iconTheme: const IconThemeData(color: Colors.white), // for back button & icons
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 6),
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(
//                 hintText: 'Enter capsule title',
//                 border: OutlineInputBorder(),
//               ),
//             ),
// Row(
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     const Text('Media', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//     IconButton(
//       icon: Icon(_showMediaSection ? Icons.expand_less : Icons.expand_more),
//       onPressed: () => setState(() => _showMediaSection = !_showMediaSection),
//     ),
//   ],
// ),
// if (_showMediaSection) ...[
//   _buildSectionCard('Photos', Icons.photo, _photoFiles, _addPhoto),
//   _buildSectionCard('Videos', Icons.videocam, _videoFiles, _addVideo),
//   _buildSectionCard('Audio', Icons.audiotrack, _audioFiles, _addAudio),
//   _buildSectionCard('Files', Icons.insert_drive_file, _otherFiles, _addFile),
// ],


//             const SizedBox(height: 10),
//             const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 6),
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   SizedBox(height: 200, child: quill.QuillEditor.basic(controller: _quillController)),
//                   if (_showToolbar) quill.QuillSimpleToolbar(controller: _quillController),
//                   IconButton(
//                     icon: Icon(_showToolbar ? Icons.expand_less : Icons.expand_more),
//                     onPressed: () => setState(() => _showToolbar = !_showToolbar),
//                   )
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),
//             const Text('Unlock Date', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 6),
//             GestureDetector(
//               onTap: _pickDate,
//               child: AbsorbPointer(
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: _selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : 'DD/MM/YYYY',
//                     suffixIcon: const Icon(Icons.calendar_today),
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 10),
//             const Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 6),
//             ToggleButtons(
//               isSelected: ['Private', 'Public', 'Specific'].map((e) => e == _privacy).toList(),
//               onPressed: (index) => setState(() => _privacy = ['Private', 'Public', 'Specific'][index]),
//               borderRadius: BorderRadius.circular(8),
//               selectedColor: Colors.white,
//               fillColor: Colors.deepPurple,
//               children: const [
//                 Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Private')),
//                 Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Public')),
//                 Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Specific')),
//               ],
//             ),

//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _handleFormSubmission,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               child: const Text('Next', style: TextStyle(fontSize: 16, color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CreateTimeCapsulePage extends StatefulWidget {
  const CreateTimeCapsulePage({super.key});

  @override
  State<CreateTimeCapsulePage> createState() => _CreateTimeCapsulePageState();
}

class _CreateTimeCapsulePageState extends State<CreateTimeCapsulePage> {
  final TextEditingController _titleController = TextEditingController();
  final quill.QuillController _quillController = quill.QuillController.basic();
  bool _showToolbar = false;
  bool _isLoading = false;
  bool _showMediaSection = false;

  DateTime? _selectedDate;
  String _privacy = 'Private';

  final ImagePicker _picker = ImagePicker();

  List<File> _photoFiles = [];
  List<File> _videoFiles = [];
  List<File> _audioFiles = [];
  List<File> _otherFiles = [];

  Future<void> _addPhoto() async {
    final status = await Permission.photos.request();
    final storageStatus = await Permission.storage.request();

    if (status.isGranted || storageStatus.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _photoFiles.add(File(image.path));
        });
      }
    } else {
      debugPrint('Permission denied');
    }
  }

  Future<void> _addVideo() async {
    final status = await Permission.photos.request();
    final storageStatus = await Permission.storage.request();

    if (status.isGranted || storageStatus.isGranted) {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _videoFiles.add(File(video.path));
        });
      }
    } else {
      debugPrint('Permission denied for video');
    }
  }

  Future<void> _addAudio() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final granted = await Permission.storage.isGranted || await Permission.manageExternalStorage.isGranted;
    if (!granted) {
      final statuses = await [Permission.storage, Permission.manageExternalStorage].request();
      if (!(statuses[Permission.storage]?.isGranted ?? false) &&
          !(statuses[Permission.manageExternalStorage]?.isGranted ?? false)) {
        debugPrint('Permission denied for audio');
        setState(() => _isLoading = false);
        return;
      }
    }

    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _audioFiles.add(File(result.files.single.path!));
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _addFile() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (await Permission.storage.isGranted || await Permission.manageExternalStorage.isGranted) {
      await _pickAnyFile();
    } else {
      final statuses = await [Permission.storage, Permission.manageExternalStorage].request();

      if (statuses[Permission.storage]!.isGranted || statuses[Permission.manageExternalStorage]!.isGranted) {
        await _pickAnyFile();
      } else {
        debugPrint('Permission denied for file');
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _otherFiles.add(File(result.files.single.path!));
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildSectionCard(String title, IconData icon, List<File> files, VoidCallback onAdd) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                const Spacer(),
                IconButton(
                  onPressed: onAdd,
                  icon: Icon(Icons.add_circle_outline, color: Colors.blue.shade700),
                  tooltip: 'Add $title',
                )
              ],
            ),
            if (files.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: files.map((file) {
                  bool isImage = file.path.endsWith('.jpg') || file.path.endsWith('.jpeg') || file.path.endsWith('.png');
                  bool isVideo = file.path.endsWith('.mp4') || file.path.endsWith('.mov') || file.path.endsWith('.avi');

                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isImage
                              ? Image.file(file, fit: BoxFit.cover)
                              : isVideo
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/video_placehorder.jpg',
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                        const Icon(Icons.play_circle_outline, size: 32, color: Colors.white),
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        file.path.split('/').last,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => files.remove(file)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              )
          ],
        ),
      ),
    );
  }

  void _handleFormSubmission() {
    final String title = _titleController.text;
    final String description = _quillController.document.toPlainText();
    debugPrint('Title: $title');
    debugPrint('Description: $description');
    debugPrint('Unlock Date: $_selectedDate');
    debugPrint('Privacy: $_privacy');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Capsule created successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  static const double _verticalSpace = 12.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: const Text('Create Capsule', style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ListView(
          children: [
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter capsule title',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),

            SizedBox(height: _verticalSpace),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.perm_media, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Add Media',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue)),
                        SizedBox(height: 4),
                        Text('Make your capsule more memorable with photos, videos, and files',
                            style: TextStyle(fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showMediaSection ? Icons.expand_less : Icons.expand_more,
                      color: Colors.blue,
                    ),
                    onPressed: () => setState(() => _showMediaSection = !_showMediaSection),
                    tooltip: _showMediaSection ? 'Hide media section' : 'Show media section',
                  ),
                ],
              ),
            ),
            if (_showMediaSection) ...[
              _buildSectionCard('Photos', Icons.photo, _photoFiles, _addPhoto),
              _buildSectionCard('Videos', Icons.videocam, _videoFiles, _addVideo),
              _buildSectionCard('Audio', Icons.audiotrack, _audioFiles, _addAudio),
              _buildSectionCard('Files', Icons.insert_drive_file, _otherFiles, _addFile),
            ],

            SizedBox(height: _verticalSpace),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 200, child: quill.QuillEditor.basic(controller: _quillController)),
                          if (_showToolbar)
                            quill.QuillSimpleToolbar(controller: _quillController),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(_showToolbar ? Icons.expand_less : Icons.expand_more, color: Colors.blue.shade700),
                              onPressed: () => setState(() => _showToolbar = !_showToolbar),
                              tooltip: _showToolbar ? 'Hide toolbar' : 'Show toolbar',
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: _verticalSpace),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Unlock Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: _selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                : 'DD/MM/YYYY',
                            suffixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade700),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: _verticalSpace),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                      ToggleButtons(
                        isSelected: ['Private', 'Public', 'Specific'].map((e) => e == _privacy).toList(),
                        onPressed: (index) => setState(() => _privacy = ['Private', 'Public', 'Specific'][index]),
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: Colors.white,
                        fillColor: Colors.blue.shade700,
                        renderBorder: false, 
                        constraints: const BoxConstraints(minHeight: 40, minWidth: 90),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Private'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Public'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Specific'),
                          ),
                        ],
                      ),

                  ],
                ),
              ),
            ),

            SizedBox(height: _verticalSpace),

            ElevatedButton(
              onPressed: _handleFormSubmission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Create Capsule', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}