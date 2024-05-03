import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:ordertaking/cart_screen.dart';
// import 'package:ordertaking/customer_details_screen.dart';
// import 'package:ordertaking/global.dart';
import 'package:pooramledger/models.dart';
import 'package:pooramledger/services.dart';
import 'package:signalr_netcore/signalr_client.dart' as sr;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class CustomerStatement extends StatefulWidget {
  final Customer customer;

  const CustomerStatement({super.key, required this.customer});

  @override
  _CustomerStatementState createState() => _CustomerStatementState();
}

class _CustomerStatementState extends State<CustomerStatement> {
  List<Ledger> futureLedger = [];
  //bool _dataLoading = true;
  sr.HubConnection? _hubConnection;
  String _reqId = Uuid().v1();
  double _bal = 0.00;
  final _dtFormat = DateFormat("dd-MM-yyyy");

  @override
  void initState() {
    super.initState();
    sendLedReq();
  }

  Future<void> openHub() async {
    if (_hubConnection == null) {
      _hubConnection = sr.HubConnectionBuilder()
          .withUrl('${Services.ServerUrl}chat')
          .withAutomaticReconnect()
          .build();

      _hubConnection!.on('LedgerProcessComplete', (args) async {
        if (args![1] == _reqId) {
          List<Ledger> a = await Services().fetchLedger(_reqId);
          setState(() {
            _bal = 0.00;
            futureLedger = a;
          });
          await clsoeHub();
        }

        //Navigator.pop(context);
        // });
      });
    }

    if (_hubConnection!.state != sr.HubConnectionState.Connected) {
      await _hubConnection!.start();
    }
    setState(() {
      //_statusText = "Connected...";
    });
  }

  Future<void> sendLedReq() async {
    try {
      await openHub();
      await _hubConnection!
          .send('GetLedgerRequest', args: [widget.customer.id, _reqId]);
    } catch (e) {
      print(e);
    }
  }

  Future<void> clsoeHub() async {
    if (_hubConnection != null) {
      if (_hubConnection!.state != sr.HubConnectionState.Disconnected) {
        await _hubConnection!.stop();
        _reqId = "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      // appBar: AppBar(
      //   title: Text(widget.customer.name!),
      //   actions: [
      //     IconButton(
      //         // onPressed: _dataLoading ? null : refreshData,
      //         onPressed: () {
      //           // Navigator.push(context,
      //           //         MaterialPageRoute(builder: (context) => SyncData()))
      //           //     .then((value) => setState(() {
      //           //           futureCustomers =
      //           //               Services().searchCustomersFromDb(_searchQuery);
      //           //         }));
      //         },
      //         icon: const Icon(Icons.send))
      //   ],
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      widget.customer.name!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                IconButton(
                    // onPressed: _dataLoading ? null : refreshData,
                    onPressed: () {
                      // Navigator.push(context,
                      //         MaterialPageRoute(builder: (context) => SyncData()))
                      //     .then((value) => setState(() {
                      //           futureCustomers =
                      //               Services().searchCustomersFromDb(_searchQuery);
                      //         }));
                    },
                    icon: const Icon(Icons.send))
              ],
            ),
            const Divider(),
            Expanded(
                child: ListView.separated(
              itemCount: futureLedger.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                // if (_searchQuery.isEmpty ||
                //     snapshot.data![index].name!
                //         .toLowerCase()
                //         .contains(_searchQuery)) {
                return prepareTile(index);
                // } else {
                //   return const SizedBox.shrink();
                // }
              },
            ))
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

  ListTile prepareTile(int index) {
    _bal += futureLedger[index].amount!;
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              futureLedger[index].docType ?? "",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              futureLedger[index].description ?? "",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              '${futureLedger[index].docNo ?? ""}  /  ${_dtFormat.format(futureLedger[index].docDate!)}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            futureLedger[index].amount! >= 0
                ? '₹ ${futureLedger[index].amount!.toStringAsFixed(2)} Dr'
                : '₹ ${(futureLedger[index].amount! * -1).toStringAsFixed(2)} Cr',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          // Text(
          //   _bal >= 0
          //       ? '${_bal.toStringAsFixed(2)} Dr'
          //       : '${(_bal * -1).toStringAsFixed(2)} Cr',
          //   style: TextStyle(fontSize: 12),
          // )
        ],
      ),

      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) =>
      //           CustomerDetailsScreen(snapshot.data![index]),
      //     ),
      //   );
      // },
    );
  }
}
