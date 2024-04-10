import 'package:flutter/material.dart';
import 'package:ordertaking/models.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  CustomerDetailsScreen(this.customer);

  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.customer.name!,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '${widget.customer.address}',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Ph: ${widget.customer.phoneNo}',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Balance: ${widget.customer.balance!.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // if (newItem != null) {
                //   newItem!.quantity = quantity;
                // } else {
                //   CartItem newItemx = CartItem(widget.product, quantity);
                //   cartItems.add(newItemx);
                // }
                Navigator.pop(context);
              },
              child: const Padding(
                  padding: EdgeInsets.all(16.0), child: Text('View Statement')),
            ),
          ],
        ),
      ),
    );
  }
}
