import 'package:flutter/material.dart';
import 'package:pooramledger/global.dart';
import 'package:pooramledger/models.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  ProductDetailsScreen(this.product);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;
  CartItem? newItem;

  @override
  void initState() {
    super.initState();
    for (var item in cartItems) {
      if (item.product.id == widget.product.id) {
        newItem = item;
        break;
      }
    }
    if (newItem != null) {
      quantity = newItem!.quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Price: \$${widget.product.price.toString()}',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(fontSize: 18.0),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) quantity--;
                        });
                      },
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (newItem != null) {
                  newItem!.quantity = quantity;
                } else {
                  CartItem newItemx = CartItem(widget.product, quantity);
                  cartItems.add(newItemx);
                }
                Navigator.pop(context);
              },
              child: const Padding(
                  padding: EdgeInsets.all(16.0), child: Text('Add to Cart')),
            ),
          ],
        ),
      ),
    );
  }
}
