import 'package:flutter/material.dart';
import 'auth/login.dart';
import 'auth/register.dart';
import 'home/home.dart';
import 'admin/admin_home.dart';
import 'capsule/create_time_capsule.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),

      localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          quill.FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // You can add more locales if needed
      ],

      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/admin_home': (context) => const AdminHomePage(),
         '/create_capsule': (context) => const CreateTimeCapsulePage(),
      },
    );
  }
}
