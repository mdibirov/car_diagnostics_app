import 'package:cloud_firestore/cloud_firestore.dart';


class ServiceRecord {
  String id;
  String carId;
  String serviceType;
  int mileage;
  int interval;
  double cost;
  DateTime date;

  ServiceRecord({
    required this.id,
    required this.carId,
    required this.serviceType,
    required this.mileage,
    required this.interval,
    required this.cost,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'serviceType': serviceType,
      'mileage': mileage,
      'interval': interval,
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
      interval: data['interval'],
      cost: data['cost'],
      date: DateTime.parse(data['date']),
    );
  }
}
