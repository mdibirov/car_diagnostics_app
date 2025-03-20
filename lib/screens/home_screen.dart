import 'package:car_diagnostics_app/screens/auth_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:car_diagnostics_app/screens/car_profile_screen.dart';
import 'package:car_diagnostics_app/screens/service_history_screen.dart';
import 'package:car_diagnostics_app/services/auth_service.dart';  // For logout function


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Function to sign out user
  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()), // Redirect to Sign In
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, ${user?.email ?? 'User'}!",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ✅ New Button - Go to Car Profile
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CarProfileScreen()),
                );
              },
              child: const Text("Go to Car Profile"),
            ),

            const SizedBox(height: 10), // Space

            // ✅ New Button - Go to Service History
            ElevatedButton(
              onPressed: () async {
                // Fetch user's cars from Firestore
                var snapshot = await FirebaseFirestore.instance.collection('cars').get();
                
                if (snapshot.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No cars found. Add a car first!")),
                  );
                  return;
                }

                // Show a list of cars to select
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Select a Car"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: snapshot.docs.map((car) {
                          return ListTile(
                            title: Text("${car["make"]} ${car["model"]}"),
                            subtitle: Text("Mileage: ${car["mileage"]} km"),
                            onTap: () {
                              String selectedCarId = car.id;
                              Navigator.pop(context); // Close dialog
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceHistoryScreen(carId: selectedCarId),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
              child: const Text("Go to Service History"),
            ),


            const SizedBox(height: 30), // Space before Sign Out


            ElevatedButton(
              onPressed: () => _signOut(context),
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}