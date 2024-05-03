import 'package:flutter/material.dart';
import 'package:pooramledger/global.dart';
import 'package:share_plus/share_plus.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (var item in cartItems) {
      total += item.product.price * item.quantity;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
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
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18.0),
              ),
              ElevatedButton(
                onPressed: () {
                  _shareCartContent(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => OrderSummaryScreen()),
                  // );
                },
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareCartContent(BuildContext context) {
    final cartContent = cartItems
        .map((item) => '${item.product.name}: ${item.quantity}')
        .join('\n');
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(cartContent,
        subject: 'Order Summary', // Optional subject for sharing
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
