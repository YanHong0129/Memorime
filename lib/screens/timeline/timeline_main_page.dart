// filepath: c:\FlutterDev\Memorime\TechTribe_MobileApp_Project\lib\admin_home.dart
import 'package:flutter/material.dart';

class TimelineMainPage extends StatelessWidget {
  const TimelineMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline Page'),
        backgroundColor: Colors.blue,

      ),
      body: Center(
        child: 
        Text(
          'Welcome to Timeline Page!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}