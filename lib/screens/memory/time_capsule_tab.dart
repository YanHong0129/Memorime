import 'package:flutter/material.dart';
import 'package:memorime_v1/models/time_capsule.dart';
import 'components/capsule_list_view.dart';
import 'components/capsule_grid_view.dart';

class TimeCapsuleTab extends StatefulWidget {
  const TimeCapsuleTab({super.key});

  @override
  State<TimeCapsuleTab> createState() => _TimeCapsuleTabState();
}

class _TimeCapsuleTabState extends State<TimeCapsuleTab> {
  bool isListView = true; // Default to list view
  final List<TimeCapsule> myCapsuleList = []; // Add your capsule data here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Share Icon Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // 👈 reduced vertical space
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Capsules",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  color: Colors.blueAccent,
                  onPressed: () {},
                  icon: Icon(Icons.screen_share_outlined),
                ),
              ],
            ),
          ),

          // Toggle View Icon Row (with less spacing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildToggleIcon(
                      icon: Icons.list_rounded,
                      isActive: isListView,
                      onTap: () {
                        setState(() {
                          isListView = true;
                        });
                      },
                    ),
                    // Optional: Add a grid icon for toggling
                    _buildToggleIcon(
                      icon: Icons.grid_view_rounded,
                      isActive: !isListView,
                      onTap: () {
                        setState(() {
                          isListView = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 6.0), // ✅ Will now apply properly

          // Capsule List/Grid
          Expanded(
            child: isListView
                ? CapsuleListView()
                : CapsuleGridView(
                  capsules: myCapsuleList,
                  month: DateTime.now(),
                ),
          ),
        ],
      ),
    );
  }
}

Widget _buildToggleIcon({
  required IconData icon,
  required bool isActive,
  required VoidCallback onTap,
}) {
  return IconButton(
    onPressed: onTap,
    icon: Icon(
      icon,
      size: 30,
      color: isActive ? Colors.blue : Colors.grey,
    ),
  );
}
