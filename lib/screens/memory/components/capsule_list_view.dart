import 'package:flutter/material.dart';

class CapsuleListView extends StatelessWidget {
  const CapsuleListView({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, String>> capsules = [
      {
        'title': 'First Dinner with Luke',
        'unlockDate': '9 MAY 2024',
        'daysLeft': '28',
        'createdDate': '9 FEB 2024',
      },
      {
        'title': 'Graduation Day',
        'unlockDate': '15 JUL 2024',
        'daysLeft': '95',
        'createdDate': '20 FEB 2024',
      },
      {
        'title': 'Trip to Japan',
        'unlockDate': '1 SEP 2024',
        'daysLeft': '143',
        'createdDate': '1 MAR 2024',
      },
    ];

    return ListView.builder(
      itemCount: capsules.length,
      itemBuilder: (context, index) {
        final capsule = capsules[index];
        return CapsuleCard(
          title: capsule['title']!,
          unlockDate: capsule['unlockDate']!,
          daysLeft: capsule['daysLeft']!,
          createdDate: capsule['createdDate']!,
        );
      },
    );
  }
}

class CapsuleCard extends StatelessWidget {
  final String title;
  final String unlockDate;
  final String daysLeft;
  final String createdDate;

  const CapsuleCard({
    super.key,
    required this.title,
    required this.unlockDate,
    required this.daysLeft,
    required this.createdDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            child: Icon(
              Icons.lock,
              color: Colors.blueAccent,
              size: 24.0,
            ),
          ),

          const SizedBox(width: 16.0),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
            
                const SizedBox(width: 6),
                const SizedBox(height: 4.0),
            
                Row(
                  children: [
                    const Icon(
                      Icons.lock_open, 
                      color: Colors.blueAccent, 
                      size: 12.0),
                    const SizedBox(width: 4.0),
                    Text(
                      'Unlock Date: $unlockDate',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
            
                    
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                          'Unlocks in $daysLeft days',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Created on: $createdDate',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.blue[300],
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            
                const SizedBox(height: 4.0),
            
              ],
            ),
          ),
        ],
        
      ),
    );
  }
}
