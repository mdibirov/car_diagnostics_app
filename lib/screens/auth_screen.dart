import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_diagnostics_app/screens/home_screen.dart';  // To navigate after login
import 'package:car_diagnostics_app/services/auth_service.dart';  // Auth logic


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '', _username = '', _phoneNumber = '';
  bool isSignUp = true;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        UserCredential userCredential;

        if (isSignUp) {
          // **Sign Up: Create new user**
          userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Account created: ${userCredential.user!.email}')),
          );
        } else {
          // **Sign In: Authenticate existing user**
          userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Signed in as: ${userCredential.user!.email}')),
          );
        }

        // Navigate to HomeScreen after successful authentication
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${e.message}')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isSignUp ? 'Sign Up' : 'Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSignUp)
                TextFormField(
                  key: const ValueKey('username'),
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => value!.isEmpty ? 'Enter a username' : null,
                  onSaved: (value) => _username = value!,
                ),
              if (isSignUp)
                TextFormField(
                  key: const ValueKey('phone'),
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Enter a phone number' : null,
                  onSaved: (value) => _phoneNumber = value!,
                ),
              TextFormField(
                key: const ValueKey('email'),
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.contains('@') ? null : 'Enter a valid email',
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                key: const ValueKey('password'),
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Password too short' : null,
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isSignUp ? 'Sign Up' : 'Sign In'),
              ),
              TextButton(
                onPressed: () => setState(() => isSignUp = !isSignUp),
                child: Text(isSignUp ? 'Already have an account? Sign In' : 'Don’t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}