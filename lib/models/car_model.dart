import 'package:cloud_firestore/cloud_firestore.dart';


class Car {
  String id;
  String make;
  String model;
  int year;
  int mileage;

  Car({required this.id, required this.make, required this.model, required this.year, required this.mileage});

  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'mileage': mileage,
    };
  }

  factory Car.fromMap(String id, Map<String, dynamic> data) {
    return Car(
      id: id,
      make: data['make'],
      model: data['model'],
      year: data['year'],
      mileage: data['mileage'],
    );
  }
}
