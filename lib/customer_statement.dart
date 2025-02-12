// import 'dart:math';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pooramledger/global.dart';
// import 'package:ordertaking/cart_screen.dart';
// import 'package:ordertaking/customer_details_screen.dart';
// import 'package:ordertaking/global.dart';
import 'package:pooramledger/models.dart';
import 'package:pooramledger/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signalr_netcore/signalr_client.dart' as sr;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class CustomerStatement extends StatefulWidget {
  final Customer customer;

  const CustomerStatement({super.key, required this.customer});

  @override
  _CustomerStatementState createState() => _CustomerStatementState();
}

class _CustomerStatementState extends State<CustomerStatement> {
  List<Ledger> futureLedger = [];
  bool _dataLoading = true;
  sr.HubConnection? _hubConnection;
  String _reqId = Uuid().v1();
  double _bal = 0.00;
  final _dtFormat = DateFormat("dd-MM-yyyy");
  String _statusText = "Fetching Data";

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
            _dataLoading = false;
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
                      generatePDF(context);
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
            Expanded(child: listview())
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

  Widget listview() {
    if (_dataLoading) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset(
          'assets/loading.gif', // Path to your GIF file
          width: 200,
          height: 200,
        ),
        const SizedBox(height: 10),
        Text(_statusText),
      ]);
    }

    return ListView.separated(
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              futureLedger[index].description ?? "",
              style:
                  const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              '${futureLedger[index].docNo ?? ""}  |  ${_dtFormat.format(futureLedger[index].docDate!)}',
              style: const TextStyle(fontSize: 12),
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

  Future<void> generatePDF(BuildContext context) async {
    if (_dataLoading) return;
    if (futureLedger.length < 2) return;

    final pdf = pw.Document();
    num rbal = 0.00;
    List<Ledger> lst = futureLedger.take(futureLedger.length - 1).toList();
    pdf.addPage(pw.MultiPage(
      header: (context) => pw.Container(
        alignment: pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.all(2),
        decoration: const pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5))),
        child: pw.Text(
          'Ledger Statement : ${widget.customer.name}',
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
      ),
      build: (context) => [
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
          // cellAlignments: {
          //   4: pw.Alignment.centerRight,
          //   5: pw.Alignment.centerRight,
          //   6: pw.Alignment.centerRight,
          columnWidths: {
            0: const pw.FixedColumnWidth(40), // doc no
            1: const pw.FixedColumnWidth(40), // date
            2: const pw.FixedColumnWidth(40), // type
            3: const pw.FixedColumnWidth(100), // remarks
            4: const pw.FixedColumnWidth(40), //debit
            5: const pw.FixedColumnWidth(40), //credit
            6: const pw.FixedColumnWidth(45), // balance
          },
          children: [
            pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.green300),
                children: [
                  headerCell('Doc No', pw.Alignment.centerLeft),
                  headerCell('Date', pw.Alignment.centerLeft),
                  headerCell('Type', pw.Alignment.centerLeft),
                  headerCell('Remarks', pw.Alignment.centerLeft),
                  headerCell('Debit', pw.Alignment.centerRight),
                  headerCell('Credit', pw.Alignment.centerRight),
                  headerCell('Balance', pw.Alignment.centerRight),
                ]),

            for (var ledger in lst)
              pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.white),
                  children: [
                    dataCell(ledger.docNo ?? ' ', pw.Alignment.centerLeft),
                    dataCell(
                        ledger.docDate != null
                            ? _dtFormat.format(ledger.docDate!)
                            : ' ',
                        pw.Alignment.centerLeft),
                    dataCell(ledger.docType ?? ' ', pw.Alignment.centerLeft),
                    dataCell(
                        ledger.description ?? ' ', pw.Alignment.centerLeft),
                    dataCell(
                        ledger.amount! >= 0
                            ? ledger.amount!.toStringAsFixed(2)
                            : ' ',
                        pw.Alignment.centerRight),
                    dataCell(
                        ledger.amount! < 0
                            ? (ledger.amount! * -1).toStringAsFixed(2)
                            : ' ',
                        pw.Alignment.centerRight),
                    dataCell(rbal.toStringAsFixed(2), pw.Alignment.centerRight),
                  ]),

            // [
            //   ledger.docNo ?? '',
            //   ledger.docDate != null
            //       ? _dtFormat.format(ledger.docDate!)
            //       : '',
            //   ledger.docType ?? '',
            //   ledger.description ?? '',
            //   ledger.amount! >= 0
            //       ? ledger.amount!.toStringAsFixed(2)
            //       : '',
            //   ledger.amount! < 0
            //       ? (ledger.amount! * -1).toStringAsFixed(2)
            //       : '',
            //   rbal.toStringAsFixed(2)
            // ],
          ],
          // headerStyle: pw.TextStyle(
          //     color: PdfColors.black,
          //     fontWeight: pw.FontWeight.bold,
          //     fontSize: 7),
          // headerDecoration: const pw.BoxDecoration(
          //     color: PdfColors.white,
          //     border: pw.Border(
          //         bottom: pw.BorderSide(color: PdfColors.white, width: .2),
          //         top: pw.BorderSide(color: PdfColors.white, width: .2),
          //         left: pw.BorderSide(color: PdfColors.white, width: 0),
          //         right: pw.BorderSide(color: PdfColors.white, width: 0))),
          // rowDecoration: const pw.BoxDecoration(
          //     border: pw.Border(
          //   bottom: pw.BorderSide(color: PdfColors.white, width: .2),
          //   top: pw.BorderSide(color: PdfColors.white, width: .2),
          //   left: pw.BorderSide.none,
          //   right: pw.BorderSide.none,
          // )),
          // cellAlignment: pw.Alignment.centerLeft,
          // cellAlignments: {
          //   4: pw.Alignment.centerRight,
          //   5: pw.Alignment.centerRight,
          //   6: pw.Alignment.centerRight,
          // },
          // columnWidths: {
          //   0: const pw.FixedColumnWidth(50),
          //   1: const pw.FixedColumnWidth(50),
          //   2: const pw.FixedColumnWidth(50),
          //   4: const pw.FixedColumnWidth(55),
          //   5: const pw.FixedColumnWidth(55),
          //   6: const pw.FixedColumnWidth(50),
          // }),
          // ],
        )
      ],
    ));

    // Save the PDF to disk
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/ledger_statement.pdf';
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(path)], text: 'Ledger Statement PDF');
  }

  pw.Widget headerCell(String text, pw.Alignment alignment) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: alignment,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.black, width: 0.5),
          bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
        ),
      ),
      child: pw.Text(text,
          style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget dataCell(String text, pw.Alignment alignment) {
    return pw.Expanded(
        child: pw.Container(
      height: 25,
      padding: const pw.EdgeInsets.all(4),
      alignment: alignment,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey, width: 0.5),
          bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
        ),
      ),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 7)),
    ));
  }
}
