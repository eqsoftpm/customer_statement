import 'package:flutter/material.dart';
import 'package:pooramledger/global.dart';
import 'models.dart';
import 'order_taking_app.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CustomerAdapter());
  await Hive.openBox<Customer>(boxCustomers);
  await Hive.openBox(boxSettings);

  runApp(OrderTakingApp());
}
