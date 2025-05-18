import 'package:flutter/material.dart';
import 'auth/login.dart';
import 'auth/register.dart';
import 'auth/forgot_password.dart';
import 'home/home.dart';
import 'admin/admin_home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomePage(),
        '/admin_home': (context) => const AdminHomePage(),
      },
    );
  }
}
