import 'package:flutter/material.dart';
import 'package:ordertaking/cart_screen.dart';
import 'package:ordertaking/customer_details_screen.dart';
import 'package:ordertaking/global.dart';
import 'package:ordertaking/models.dart';
import 'package:ordertaking/services.dart';
import 'package:ordertaking/sync_data.dart';
import 'package:signalr_netcore/signalr_client.dart' as sr;

class CustomerListScreen extends StatefulWidget {
  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  late Future<List<Customer>> futureCustomers;
  bool _dataLoading = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  sr.HubConnection? _hubConnection;

  @override
  void initState() {
    super.initState();
    //Services().downloadCustomers();
    futureCustomers = Services().searchCustomersFromDb(null);
  }

  Future<void> openHub() async {
    if (_hubConnection == null) {
      _hubConnection = sr.HubConnectionBuilder()
          .withUrl('${Services.ServerUrl}chat')
          .withAutomaticReconnect()
          .build();

      _hubConnection!.on('CustomersUploadComplete', (args) {
        // setState(() {
        futureCustomers = Services().fetchCustomersFromDb();

        // });
      });
    }

    if (_hubConnection!.state != sr.HubConnectionState.Connected) {
      await _hubConnection!.start();
    }
  }

  Future<void> sendCustReq() async {
    await openHub();
    await _hubConnection!.send('GetCustomersRequest');
  }

  Future<void> clsoeHub() async {
    if (_hubConnection != null) {
      if (_hubConnection!.state != sr.HubConnectionState.Disconnected) {
        await _hubConnection!.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
              // onPressed: _dataLoading ? null : refreshData,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SyncData()));
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
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _dataLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print(snapshot);
                  _dataLoading = false;
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  _dataLoading = false;
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
                          subtitle:
                              Text('Ph:${snapshot.data![index].phoneNo ?? ""}'),
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => CartScreen(),
      //       ),
      //     );
      //   },
      //   child: const Icon(Icons.send),
      // ),
    );
  }

  void refreshData() {
    // print('sync clicked');
    setState(() {
      _dataLoading = true;
      //futureCustomers = Services().fetchCustomersFromDb();
      futureCustomers = Future<List<Customer>>.value([]);
      sendCustReq();
    });
  }
}
