// filepath: c:\FlutterDev\Memorime\TechTribe_MobileApp_Project\lib\admin_home.dart
import 'package:flutter/material.dart';

class FriendsMainPage extends StatelessWidget {
  const FriendsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends Page'),
        backgroundColor: Colors.blue,

      ),
      body: Center(
        child: 
        Text(
          'Welcome to Friends Page!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}