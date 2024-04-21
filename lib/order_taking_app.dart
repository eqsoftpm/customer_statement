import 'package:flutter/material.dart';
import 'package:ordertaking/customer_list_screen.dart';

class OrderTakingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Taking App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CustomerListScreen(),
    );
  }
}
