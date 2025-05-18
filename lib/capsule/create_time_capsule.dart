import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateTimeCapsulePage extends StatefulWidget {
  const CreateTimeCapsulePage({super.key});

  @override
  State<CreateTimeCapsulePage> createState() => _CreateTimeCapsulePageState();
}

class _CreateTimeCapsulePageState extends State<CreateTimeCapsulePage> {
  final TextEditingController _titleController = TextEditingController();
  final quill.QuillController _quillController = quill.QuillController.basic();
  bool _showToolbar = true;

  DateTime? _selectedDate;
  String _privacy = 'Private';

  final ImagePicker _picker = ImagePicker();

  Future<void> insertImage() async {
    final status = await Permission.photos.request();
    final storageStatus = await Permission.storage.request();

    if (status.isGranted || storageStatus.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageUrl = image.path; // Use the local path
        final index = _quillController.selection.baseOffset;

        _quillController.replaceText(
          index,
          0,
          quill.BlockEmbed.image(imageUrl),
          TextSelection.collapsed(offset: index + 1),
        );
      }
    } else {
      debugPrint('Permission denied');
    }
  }

  Future<void> insertVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      final videoUri = File(video.path).uri.toString();
      final index = _quillController.selection.baseOffset;

      _quillController.replaceText(
        index,
        0,
        quill.BlockEmbed.video(videoUri),
        const TextSelection.collapsed(offset: 0),
      );
    }
  }

  Future<void> insertAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      final audioPath = result.files.single.path!;
      final index = _quillController.selection.baseOffset;

      _quillController.replaceText(
        index,
        0,
        '\nAudio: $audioPath\n',
        const TextSelection.collapsed(offset: 0),
      );
    }
  }

  Future<void> insertFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final index = _quillController.selection.baseOffset;

      _quillController.replaceText(
        index,
        0,
        '\nFile: $filePath\n',
        const TextSelection.collapsed(offset: 0),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildPrivacyOption(String label) {
    final bool isSelected = _privacy == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _privacy = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.deepPurple),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleFormSubmission() {
    final String title = _titleController.text;
    final String descriptionJson = _quillController.document.toDelta().toJson().toString();
    final String? unlockDate = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null;

    // For demo: print to console (you can replace this with database save or API call)
    debugPrint('Title: $title');
    debugPrint('Description: $descriptionJson');
    debugPrint('Unlock Date: $unlockDate');
    debugPrint('Privacy: $_privacy');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Capsule created successfully!')),
    );

    Navigator.pop(context); // or navigate to another page
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Capsule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ListView(
          children: [
            const Text('Capsule Title', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter capsule title',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quill editor (input box) first
                  SizedBox(
                    height: 200,
                    child: quill.QuillEditor.basic(
                      controller: _quillController,
                    ),
                  ),

                  // Toolbar toggle button
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        _showToolbar ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey,
                      ),
                      tooltip: _showToolbar ? 'Hide Toolbar' : 'Show Toolbar',
                      onPressed: () {
                        setState(() {
                          _showToolbar = !_showToolbar;
                        });
                      },
                    ),
                  ),

                  // Conditional toolbar
                  if (_showToolbar)
                    quill.QuillSimpleToolbar(controller: _quillController),

                  // Media buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: insertImage,
                        tooltip: 'Insert Image',
                      ),
                      IconButton(
                        icon: const Icon(Icons.videocam),
                        onPressed: insertVideo,
                        tooltip: 'Insert Video',
                      ),
                      IconButton(
                        icon: const Icon(Icons.music_note),
                        onPressed: insertAudio,
                        tooltip: 'Insert Audio',
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: insertFile,
                        tooltip: 'Insert File',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Date Unlock', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: _selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                        : 'DD/MM/YYYY',
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPrivacyOption('Private'),
                _buildPrivacyOption('Public'),
                _buildPrivacyOption('Specific'),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleFormSubmission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
