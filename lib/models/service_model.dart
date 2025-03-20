import 'package:cloud_firestore/cloud_firestore.dart';


class ServiceRecord {
  String id;
  String carId;
  String serviceType;
  int mileage;
  int intervalKm;
  double cost;
  DateTime date;

  ServiceRecord({
    required this.id,
    required this.carId,
    required this.serviceType,
    required this.mileage,
    required this.intervalKm,
    required this.cost,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'serviceType': serviceType,
      'mileage': mileage,
      'intervalKm': intervalKm,
      'cost': cost,
      'date': date.toIso8601String(),
    };
  }

  factory ServiceRecord.fromMap(String id, Map<String, dynamic> data) {
    return ServiceRecord(
      id: id,
      carId: data['carId'],
      serviceType: data['serviceType'],
      mileage: data['mileage'],
      intervalKm: data['intervalKm'],
      cost: data['cost'],
      date: DateTime.parse(data['date']),
    );
  }
}
