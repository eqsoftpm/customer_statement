import 'package:flutter/material.dart';
import 'package:pooramledger/customer_statement.dart';
import 'package:pooramledger/models.dart';

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
      appBar: null,
      // appBar: AppBar(
      //   elevation: 0,
      //   title: const Text(
      //     'Customer Details',
      //     style: TextStyle(color: Colors.black),
      //   ),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 64,
                child: Image.network(
                    "https://avatar.iran.liara.run/public/boy?username=Ash"),
              ),
              const SizedBox(height: 20.0),
              Center(
                child: Text(
                  widget.customer.name!,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${widget.customer.address ?? ''}',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Ph: ${widget.customer.phoneNo}',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Balance: ${widget.customer.balance! < 0 ? widget.customer.balance!.toStringAsFixed(2) + ' Cr' : widget.customer.balance!.toStringAsFixed(2) + ' Dr'}',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CustomerStatement(customer: widget.customer),
                    ),
                  );

                  // if (newItem != null) {
                  //   newItem!.quantity = quantity;
                  // } else {
                  //   CartItem newItemx = CartItem(widget.product, quantity);
                  //   cartItems.add(newItemx);
                  // }
                  //Navigator.pop(context);
                },
                child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('View Statement')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
