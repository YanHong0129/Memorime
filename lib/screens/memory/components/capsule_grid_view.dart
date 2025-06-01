import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CapsuleGridView extends StatelessWidget {
  const CapsuleGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Text(
              "May 2024",
              style: GoogleFonts.lora(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
          ),
          
          // Grid View
          Expanded(
            child: GridView.builder(
              itemCount: 31,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: index == 5 ? Colors.blueAccent : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: index == 5
                      ? const Icon(Icons.lock, color: Colors.white, size: 20)
                      : const SizedBox(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


