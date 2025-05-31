import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure this import is present

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late String role;

  @override
  void initState() {
    super.initState();
  }

  bool _isObscured1 = true;

  Future<void> login() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null && user.emailVerified) {
        // Check if user email is in admin list
        final adminDoc = await FirebaseFirestore.instance
            .collection('config')
            .doc('admins')
            .get();

        final adminEmails = List<String>.from(adminDoc.data()?['email'] ?? []);
        final isAdmin = adminEmails.contains(user.email);

        if (isAdmin) {
          // Navigate to admin home page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Welcome Admin!")),
          );
          Navigator.pushNamed(context, '/admin_home');
        } else {
          // Navigate to user home page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login successful")),
          );
          Navigator.pushNamed(context, '/home');
        }
      } else {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email not verified. Please check your inbox.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body:SafeArea(
        child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
          
              Text(
                'Welcome to ',
                style: GoogleFonts.bebasNeue(
                  fontSize: 40,
                )
                ),
              Image.asset(
                'assets/images/memorime_logo_removebg.png',
                height: 150,
                width: 150,
              ),
              Text(
                'Let\'s Begin Your Jouney',
                style: GoogleFonts.dancingScript(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                )
                ),
          
              SizedBox(height: 20),
          
              // Email Textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left:20.0, top:5),
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                        ),
                    ),
                  ),
                ),
              ),
          
              SizedBox(height: 10),
          
              // Password Textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left:20.0, top: 5),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: _isObscured1,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          padding: EdgeInsets.only(right: 10, bottom: 5),
                      icon: Icon(
                        _isObscured1 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured1 = !_isObscured1;
                        });
                      },
                    ),
                        ),      
                    ),
                  ),
                ),
              ),
          
              SizedBox(height: 5),
              // Forgot Password
          
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                      child: Text(
                        'Forgot Password?',
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold
                      ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
          
              // Login Button
          
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: login,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
                    )),
                ),
              ),
          
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t have an account? ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold
                    ),),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      ' Register now',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
