import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(OrderTakingApp());
}

class OrderTakingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Taking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: customerListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> futureProducts;

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Products',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  if (snapshot.hasData) {
                    snapshot.data!.sort((a, b) => a.name.compareTo(b.name));
                  }
                  return ListView.builder(
                    itemCount: (snapshot.hasData ? snapshot.data!.length : 0),
                    itemBuilder: (context, index) {
                      if (_searchQuery.isEmpty ||
                          snapshot.data![index].name
                              .toLowerCase()
                              .contains(_searchQuery)) {
                        return ListTile(
                          title: Text(snapshot.data![index].name),
                          subtitle: Text(
                              'Price: \$${snapshot.data![index].price.toStringAsFixed(2)}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(snapshot.data![index]),
                              ),
                            );
                          },
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartScreen(),
            ),
          );
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}

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
        title: Text('Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Price: \$${widget.product.price.toString()}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity:',
                  style: TextStyle(fontSize: 18.0),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) quantity--;
                        });
                      },
                    ),
                    Text(
                      quantity.toString(),
                      style: TextStyle(fontSize: 18.0),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
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
            SizedBox(height: 16.0),
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

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (var item in cartItems) {
      total += item.product.price * item.quantity;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Order'),
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
                style: TextStyle(fontSize: 18.0),
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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
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

class OrderSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Summary'),
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

class customerListScreen extends StatefulWidget {
  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<customerListScreen> {
  late Future<List<Customer>> futureCustomers;

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureCustomers = fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Customers',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Customer>>(
              future: futureCustomers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print(snapshot);
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  if (snapshot.hasData) {
                    snapshot.data!.sort((a, b) => a.name!.compareTo(b.name!));
                  }
                  return ListView.builder(
                    itemCount: (snapshot.hasData ? snapshot.data!.length : 0),
                    itemBuilder: (context, index) {
                      if (_searchQuery.isEmpty ||
                          snapshot.data![index].name!
                              .toLowerCase()
                              .contains(_searchQuery)) {
                        return ListTile(
                          title: Text(snapshot.data![index].name!),
                          subtitle: Text(
                              'Price: Ph:${snapshot.data![index].phoneNo!}'),
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         ProductDetailsScreen(snapshot.data![index]),
                            //   ),
                            // );
                          },
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartScreen(),
            ),
          );
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? discountPercentage;
  final double? rating;
  final int? stock;
  final String? brand;
  final String? category;
  final String? thumbnail;

  Product(
      this.id,
      this.name,
      this.description,
      this.price,
      this.discountPercentage,
      this.rating,
      this.stock,
      this.brand,
      this.category,
      this.thumbnail);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        json['id'],
        json['title'],
        json['description'],
        json['price'].toDouble(),
        json['discountPercentage'].toDouble(),
        json['rating'].toDouble(),
        json['stock'],
        json['brand'],
        json['category'],
        json['thumbnail']);
  }
}

Future<List<Product>> fetchProducts() async {
  final response =
      await http.get(Uri.parse('https://dummyjson.com/products?limit=100'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    List<dynamic> productsData = jsonData['products'];
    return productsData.map((item) => Product.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}

Future<List<Customer>> fetchCustomers() async {
  print('starting fetch');
  final response = await http.get(Uri.parse(
      'https://live.eqsoftonline.com/SalesSyncApp/Apiv1/Customers?CompanyId=54'));
  print(response);
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    //List<dynamic> productsData = jsonData['products'];
    return jsonData.map((item) => Customer.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load customers');
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem(this.product, this.quantity);
}

// List<Product> products = [
//   Product('Product 1', 10.0),
//   Product('Product 2', 15.0),
//   Product('Product 3', 20.0),
//   Product('Product 4', 25.0),
// ];

List<CartItem> cartItems = [];
List<Customer> customers = [];

class Customer {
  int id;
  int companyId;
  int refId;
  String? name;
  String? address;
  String? phoneNo;
  String? gstin;
  String? email;
  double? balance;
  String? place;
  String? pincode;
  double? latitude;
  double? longitude;

  Customer(
      this.id,
      this.companyId,
      this.refId,
      this.name,
      this.address,
      this.phoneNo,
      this.gstin,
      this.email,
      this.balance,
      this.place,
      this.pincode,
      this.latitude,
      this.longitude);

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
      json['Id'],
      json['CompanyId'],
      json['RefId'],
      json['Name'],
      json['Address'],
      json['PhoneNo'],
      json['GSTIN'],
      json['Email'],
      json['Balance'],
      json['Place'],
      json['Pincode'],
      json['Latitude'],
      json['Longitude']);

  Map<String, dynamic> toJson() => {
        "Id": id,
        "CompanyId": companyId,
        "RefId": refId,
        "Name": name,
        "Address": address,
        "PhoneNo": phoneNo,
        "GSTIN": gstin,
        "Email": email,
        "Balance": balance,
        "Place": place,
        "Pincode": pincode,
        "Latitude": latitude,
        "Longitude": longitude,
      };
}
