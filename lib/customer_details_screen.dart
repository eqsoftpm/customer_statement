import 'package:flutter/material.dart';
import 'package:pooramledger/customer_statement.dart';
import 'package:pooramledger/models.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back))
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 64,
                      child: Image.asset("assets/boy.png"),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      widget.customer.name!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${widget.customer.address ?? ''}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Ph: ${widget.customer.phoneNo}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Balance: ${widget.customer.balance! < 0 ? widget.customer.balance!.toStringAsFixed(2) + ' Cr' : widget.customer.balance!.toStringAsFixed(2) + ' Dr'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerStatement(
                                    customer: widget.customer),
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
                    const SizedBox(
                      height: 10,
                    ),
                    OutlinedButton(
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.phone_in_talk_rounded),
                      ),
                      onPressed: () {
                        launchUrlString(
                            "tel://${widget.customer.phoneNo ?? ""}");
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
