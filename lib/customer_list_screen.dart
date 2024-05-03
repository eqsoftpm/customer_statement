import 'package:flutter/material.dart';
// import 'package:ordertaking/cart_screen.dart';
import 'package:pooramledger/customer_details_screen.dart';
// import 'package:ordertaking/global.dart';
import 'package:pooramledger/models.dart';
import 'package:pooramledger/services.dart';
import 'package:pooramledger/sync_data.dart';
import 'package:url_launcher/url_launcher_string.dart';
//import 'package:signalr_netcore/signalr_client.dart' as sr;

class CustomerListScreen extends StatefulWidget {
  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  late Future<List<Customer>> futureCustomers;
  bool _dataLoading = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  //sr.HubConnection? _hubConnection;

  @override
  void initState() {
    super.initState();
    //Services().downloadCustomers();
    futureCustomers = Services().searchCustomersFromDb(null);
  }

  // Future<void> openHub() async {
  //   if (_hubConnection == null) {
  //     _hubConnection = sr.HubConnectionBuilder()
  //         .withUrl('${Services.ServerUrl}chat')
  //         .withAutomaticReconnect()
  //         .build();

  //     _hubConnection!.on('CustomersUploadComplete', (args) {
  //       // setState(() {
  //       futureCustomers = Services().fetchCustomersFromDb();

  //       // });
  //     });
  //   }

  //   if (_hubConnection!.state != sr.HubConnectionState.Connected) {
  //     await _hubConnection!.start();
  //   }
  // }

  // Future<void> sendCustReq() async {
  //   await openHub();
  //   await _hubConnection!.send('GetCustomersRequest');
  // }

  // Future<void> clsoeHub() async {
  //   if (_hubConnection != null) {
  //     if (_hubConnection!.state != sr.HubConnectionState.Disconnected) {
  //       await _hubConnection!.stop();
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      // appBar: AppBar(
      //   title: const Text('Customers'),
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //         // onPressed: _dataLoading ? null : refreshData,
      //         onPressed: () {
      //           Navigator.push(context,
      //                   MaterialPageRoute(builder: (context) => SyncData()))
      //               .then((value) => setState(() {
      //                     futureCustomers =
      //                         Services().searchCustomersFromDb(_searchQuery);
      //                   }));
      //         },
      //         icon: const Icon(Icons.sync))
      //   ],
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
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
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      // onPressed: _dataLoading ? null : refreshData,
                      onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SyncData()))
                            .then((value) => setState(() {
                                  futureCustomers = Services()
                                      .searchCustomersFromDb(_searchQuery);
                                }));
                      },
                      icon: const Icon(Icons.sync)),
                )
              ],
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
                    return ListView.separated(
                      itemCount: (snapshot.hasData ? snapshot.data!.length : 0),
                      itemBuilder: (context, index) {
                        if (_searchQuery.isEmpty ||
                            snapshot.data![index].name!
                                .toLowerCase()
                                .contains(_searchQuery)) {
                          return ListTile(
                            leading: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                              child: CircleAvatar(
                                backgroundColor: Colors.black87,
                                child: Text(
                                  snapshot.data![index].name!.substring(0, 1),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            trailing: TextButton(
                              child: Icon(Icons.phone_in_talk_rounded),
                              onPressed: () {
                                launchUrlString(
                                    "tel://${snapshot.data![index].phoneNo ?? ""}");
                              },
                            ),
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data![index].name!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Ph:${snapshot.data![index].phoneNo ?? ""}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                      separatorBuilder: (context, index) => const Divider(),
                    );
                  }
                },
              ),
            )
          ],
        ),
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

  // void refreshData() {
  //   // print('sync clicked');
  //   setState(() {
  //     _dataLoading = true;
  //     //futureCustomers = Services().fetchCustomersFromDb();
  //     futureCustomers = Future<List<Customer>>.value([]);
  //     sendCustReq();
  //   });
  // }
}
