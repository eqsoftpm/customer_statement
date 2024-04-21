import 'package:flutter/material.dart';
import 'package:ordertaking/models.dart';
import 'package:ordertaking/services.dart';
import 'package:signalr_netcore/signalr_client.dart' as sr;

class SyncData extends StatefulWidget {
  @override
  _SyncDataState createState() => _SyncDataState();
}

class _SyncDataState extends State<SyncData> {
  late Future<List<Customer>> futureCustomers;
  sr.HubConnection? _hubConnection;
  String _statusText = "Syncing Data";

  @override
  void initState() {
    super.initState();
    // Start synchronization process when screen is opened
    startSync();
  }

  Future<void> openHub() async {
    if (_hubConnection == null) {
      _hubConnection = sr.HubConnectionBuilder()
          .withUrl('${Services.ServerUrl}chat')
          .withAutomaticReconnect()
          .build();

      _hubConnection!.on('CustomersUploadComplete', (args) async {
        // setState(() {
        setState(() {
          _statusText = "Download in Progress";
        });
        await Services().downloadCustomers();
        await clsoeHub();

        setState(() {
          _statusText = "Download Completed";
        });

        Navigator.pop(context);
        // });
      });
    }

    if (_hubConnection!.state != sr.HubConnectionState.Connected) {
      await _hubConnection!.start();
    }
    setState(() {
      _statusText = "Connected...";
    });
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

  void startSync() async {
    // Simulated synchronization process
    //await Future.delayed(Duration(seconds: 5)); // Simulating 3 seconds delay

    await sendCustReq();
    // Once synchronization is complete, navigate back
    //Navigator.pop(context);
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to cancel the synchronization?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sync Customers'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'loading.gif', // Path to your GIF file
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 16),
              Text(_statusText),
            ],
          ),
        ),
      ),
    );
  }
}
