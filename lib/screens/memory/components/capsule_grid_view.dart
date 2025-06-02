import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memorime_v1/models/time_capsule.dart';

class CapsuleGridView extends StatelessWidget {
  final List<TimeCapsule> capsules;
  final DateTime month;
  const CapsuleGridView({
    super.key,
    required this.capsules,
    required this.month,
    });

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final String monthTitle =
        "${_monthName(month.month)} ${month.year}";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Text(
              monthTitle,
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
                final day = index + 1;
                final hasCapsule = capsules.any((capsule) =>
                    capsule.unlockDate.day == day &&
                    capsule.unlockDate.month == month.month &&
                    capsule.unlockDate.year == month.year);

                return GestureDetector(
                  onTap: hasCapsule
                      ? () {
                          // Handle capsule tap
                          // Navigate to capsule details or unlock logic
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: index == 5 ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: hasCapsule
                        ? const Icon(Icons.lock, color: Colors.white, size: 20)
                        : Padding(
                          padding: const EdgeInsets.only(left: 4.0, top: 1.0),
                          child: Text(
                            "$day",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _monthName(int month) {
  const months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[month];
}



