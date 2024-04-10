import 'package:flutter/material.dart';
import 'package:ordertaking/cart_screen.dart';
import 'package:ordertaking/customer_details_screen.dart';
import 'package:ordertaking/models.dart';
import 'package:ordertaking/services.dart';

class customerListScreen extends StatefulWidget {
  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<customerListScreen> {
  late Future<List<Customer>> futureCustomers;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    //Services().downloadCustomers();
    futureCustomers = Services().searchCustomersFromDb(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
              onPressed: () {
                print('sync clicked');
                setState(() {
                  futureCustomers = Services().fetchCustomersFromDb();
                });
              },
              icon: const Icon(Icons.sync))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Customers',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                  futureCustomers =
                      Services().searchCustomersFromDb(_searchQuery);
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Customer>>(
              future: futureCustomers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerDetailsScreen(
                                    snapshot.data![index]),
                              ),
                            );
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
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
