import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:car_diagnostics_app/models/car_model.dart';  // Car Data Model
import 'package:car_diagnostics_app/services/firebase_service.dart';  // Firestore operations



class CarProfileScreen extends StatefulWidget {
  @override
  _CarProfileScreenState createState() => _CarProfileScreenState();
}

class _CarProfileScreenState extends State<CarProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addOrEditCar({String? docId, String? make, String? model, String? year, String? mileage}) async {
    TextEditingController makeController = TextEditingController(text: make);
    TextEditingController modelController = TextEditingController(text: model);
    TextEditingController yearController = TextEditingController(text: year);
    TextEditingController mileageController = TextEditingController(text: mileage);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Add New Car' : 'Edit Car'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: makeController, decoration: InputDecoration(labelText: 'Make')),
              TextField(controller: modelController, decoration: InputDecoration(labelText: 'Model')),
              TextField(controller: yearController, decoration: InputDecoration(labelText: 'Year')),
              TextField(controller: mileageController, decoration: InputDecoration(labelText: 'Mileage')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (makeController.text.isNotEmpty && modelController.text.isNotEmpty) {
                  // Close the dialog before updating Firestore
                  Navigator.pop(context);

                  if (docId == null) {
                    // Adding new car
                    await _firestore.collection('cars').add({
                      'make': makeController.text,
                      'model': modelController.text,
                      'year': yearController.text,
                      'mileage': mileageController.text,
                    });
                  } else {
                    // Editing existing car
                    await _firestore.collection('cars').doc(docId).update({
                      'make': makeController.text,
                      'model': modelController.text,
                      'year': yearController.text,
                      'mileage': mileageController.text,
                    });
                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _deleteCar(String docId) async {
    await _firestore.collection('cars').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Car Profile')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cars').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          var cars = snapshot.data!.docs;

          return cars.isEmpty
              ? Center(child: Text("No cars added yet."))
              : ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    var car = cars[index];
                    return ListTile(
                      title: Text("${car['make']} ${car['model']}"),
                      subtitle: Text("Year: ${car['year']} - Mileage: ${car['mileage']} km"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _addOrEditCar(
                              docId: car.id,
                              make: car['make'],
                              model: car['model'],
                              year: car['year'],
                              mileage: car['mileage'],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCar(car.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addOrEditCar(),
      ),
    );
  }
}