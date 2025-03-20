import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_diagnostics_app/models/car_model.dart';
import 'package:car_diagnostics_app/models/service_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add Car to Firestore
  Future<void> addCar(Car car) async {
    await _db.collection('cars').doc(car.id).set(car.toMap());
  }

  // Add Service Record
  Future<void> addService(ServiceRecord service) async {
    await _db.collection('services').doc(service.id).set(service.toMap());
  }
}
