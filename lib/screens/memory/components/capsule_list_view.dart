import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/time_capsule.dart';
import '../../../repository/capsule_repository.dart';
import '../../../services/capsule_firestore_service.dart';
import '../capsule_detailsPage.dart.dart';

class CapsuleListView extends StatelessWidget {
  const CapsuleListView({super.key});
  

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final CapsuleRepository _repository = CapsuleRepository(CapsuleFirestoreService(userId));


    return StreamBuilder<List<TimeCapsule>>(
      stream: _repository.streamCapsules(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No capsules found."));
        }

        final capsules = snapshot.data!;

        return ListView.builder(
          itemCount: capsules.length,
          itemBuilder: (context, index) {
            final capsule = capsules[index];
            final now = DateTime.now();

            // Calculate days left
            final daysLeft = capsule.unlockDate.difference(DateTime.now()).inDays;
            final isUnlocked = capsule.unlockDate.isBefore(now) ||
                                    capsule.unlockDate.year == now.year &&
                                    capsule.unlockDate.month == now.month &&
                                    capsule.unlockDate.day == now.day;

            return GestureDetector(
              onTap: isUnlocked
                  ? (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:(_) => CapsuleDetailPage(capsule: capsule),)
                      );
                  }: null,
              child: CapsuleCard(
                title: capsule.title,
                unlockDate: _formatDate(capsule.unlockDate),
                daysLeft: daysLeft.toString(),
                createdDate: _formatDate(capsule.createdAt),
                isUnlocked: isUnlocked,
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day} ${_monthName(date.month)} ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month];
  }
}


class CapsuleCard extends StatelessWidget {
  final String title;
  final String unlockDate;
  final String daysLeft;
  final String createdDate;
  final bool isUnlocked;

  const CapsuleCard({
    super.key,
    required this.title,
    required this.unlockDate,
    required this.daysLeft,
    required this.createdDate,
    required this.isUnlocked,
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
              isUnlocked ? Icons.lock_open: Icons.lock,
              color: isUnlocked ? Colors.green : Colors.blueAccent,
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
