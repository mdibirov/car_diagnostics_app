import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:car_diagnostics_app/models/service_model.dart';  // Service Data Model
import 'package:car_diagnostics_app/services/firebase_service.dart';  // Firestore operations



class ServiceHistoryScreen extends StatefulWidget {
  final String carId;

  const ServiceHistoryScreen({Key? key, required this.carId}) : super(key: key);

  @override
  _ServiceHistoryScreenState createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addService() async {
    String serviceType = '';
    String mileageDuringService = '';
    String serviceInterval = '';
    String cost = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Service"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                items: ["Oil Change", "Tire Rotation", "Brake Check"]
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => serviceType = value!,
                decoration: const InputDecoration(labelText: "Service Type"),
              ),
              TextField(
                onChanged: (value) => mileageDuringService = value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Mileage During Service (km)"),
              ),
              TextField(
                onChanged: (value) => serviceInterval = value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Service Interval (km)"),
              ),
              TextField(
                onChanged: (value) => cost = value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Cost"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (serviceType.isNotEmpty && mileageDuringService.isNotEmpty && serviceInterval.isNotEmpty) {
                  int mileage = int.parse(mileageDuringService);
                  int interval = int.parse(serviceInterval);
                  int nextServiceDue = mileage + interval;

                  await _firestore
                      .collection("cars")
                      .doc(widget.carId)
                      .collection("services")
                      .add({
                    "serviceType": serviceType,
                    "mileage": mileage,
                    "interval": interval,
                    "cost": cost,
                    "nextServiceDue": nextServiceDue,
                    "timestamp": FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _editServiceRecord(DocumentSnapshot service) {
    String serviceType = service["serviceType"];
    String _mileage = service["mileage"].toString();
    String _interval = service["interval"].toString();
    String _cost = service["cost"]?.toString() ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Service Record"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: serviceType,
                onChanged: (value) {
                  setState(() {
                    serviceType = value!;
                  });
                },
                items: ["Oil Change", "Brake Check", "Tire Rotation", "Battery Replacement"]
                    .map((service) => DropdownMenuItem(
                          value: service,
                          child: Text(service),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: "Service Type"),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Mileage during service"),
                initialValue: _mileage,
                onChanged: (value) => _mileage = value,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Service Interval (km)"),
                initialValue: _interval,
                onChanged: (value) => _interval = value,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Cost (optional)"),
                initialValue: _cost,
                onChanged: (value) => _cost = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                int mileage = int.parse(_mileage);
                int interval = int.parse(_interval);
                int nextServiceDue = mileage + interval;

                await FirebaseFirestore.instance
                    .collection("cars")
                    .doc(widget.carId)
                    .collection("services")
                    .doc(service.id)
                    .update({
                  "serviceType": serviceType,
                  "mileage": mileage,
                  "interval": interval,
                  "cost": _cost.isEmpty ? null : double.parse(_cost),
                  "nextServiceDue": nextServiceDue,
                });

                Navigator.pop(context);
              },
              child: const Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  void _deleteServiceRecord(String serviceId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Service Record?"),
          content: const Text("Are you sure you want to delete this service entry?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      await FirebaseFirestore.instance
          .collection("cars")
          .doc(widget.carId)
          .collection("services")
          .doc(serviceId)
          .delete();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Service History")),
      body: StreamBuilder(
        stream: _firestore
            .collection("cars")
            .doc(widget.carId)
            .collection("services")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var services = snapshot.data!.docs;
          
          if (services.isEmpty) {
            return const Center(child: Text("No services recorded yet."));
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              var service = services[index];
              return ListTile(
                title: Text(service["serviceType"]),
                subtitle: Text(
                    "Mileage: ${service["mileage"]} km | Next: ${service["nextServiceDue"]} km"),
                trailing: Text("\$${service["cost"] ?? "N/A"}"),
                onTap: () => _editServiceRecord(service), // New function to edit service
                onLongPress: () => _deleteServiceRecord(service.id), // Delete on long press
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addService,
        child: const Icon(Icons.add),
      ),
    );
  }
}