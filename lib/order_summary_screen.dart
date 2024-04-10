import 'package:flutter/material.dart';
import 'package:ordertaking/global.dart';

class OrderSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
      ),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cartItems[index].product.name),
            subtitle: Text(
                'Price: \$${cartItems[index].product.price.toString()}, Quantity: ${cartItems[index].quantity.toString()}'),
          );
        },
      ),
    );
  }
}

/*  *******************************  */

// List<Product> products = [
//   Product('Product 1', 10.0),
//   Product('Product 2', 15.0),
//   Product('Product 3', 20.0),
//   Product('Product 4', 25.0),
// ];
