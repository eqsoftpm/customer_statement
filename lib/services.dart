import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:ordertaking/global.dart';
import 'package:ordertaking/models.dart';

class Services {
  static const String ServerUrl = 'https://localhost:44356/';

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

  Future<void> downloadCustomers() async {
    final box = Hive.box<Customer>(boxCustomers);
    await box.clear();
    final lst = await _fetchCustomers();
    for (var item in lst) {
      await box.add(item);
    }
  }

  Future<List<Customer>> _fetchCustomers() async {
    print('starting fetch');
    final response = await http
        .get(Uri.parse('${ServerUrl}api/Ledger/Customers?page=0&count=0'));
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      //List<dynamic> productsData = jsonData['products'];
      return jsonData.map((item) => Customer.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load customers');
    }
  }

  Future<List<Customer>> fetchCustomersFromDb() async {
    await downloadCustomers();
    final box = Hive.box<Customer>(boxCustomers);
    return box.values.toList();
  }

  Future<List<Customer>> searchCustomersFromDb(String? query) async {
    final box = Hive.box<Customer>(boxCustomers);
    if (query != null) {
      return box.values.where((x) => x.name!.contains(query)).toList();
    } else {
      return box.values.toList();
    }
  }
}
