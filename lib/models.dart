import 'package:hive/hive.dart';
part 'models.g.dart';

@HiveType(typeId: 0)
class Customer {
  @HiveField(0)
  int id;
  @HiveField(1)
  int? companyId;
  @HiveField(2)
  int? refId;
  @HiveField(3)
  String? name;
  @HiveField(4)
  String? address;
  @HiveField(5)
  String? phoneNo;
  @HiveField(6)
  String? gstin;
  @HiveField(7)
  String? email;
  @HiveField(8)
  num? balance;
  @HiveField(9)
  String? place;
  @HiveField(10)
  String? pincode;
  @HiveField(11)
  double? latitude;
  @HiveField(12)
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
      json['id'],
      json['CompanyId'],
      json['RefId'],
      json['name'],
      json['address'],
      json['phone'],
      json['gstin'],
      json['Email'],
      json['balance'],
      json['Place'],
      json['Pincode'],
      json['Latitude'],
      json['Longitude']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "CompanyId": companyId,
        "RefId": refId,
        "name": name,
        "address": address,
        "phone": phoneNo,
        "gstin": gstin,
        "Email": email,
        "balance": balance,
        "Place": place,
        "Pincode": pincode,
        "Latitude": latitude,
        "Longitude": longitude,
      };
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

class CartItem {
  final Product product;
  int quantity;

  CartItem(this.product, this.quantity);
}

class Ledger {
  int id;
  String? docId;
  String? docNo;
  String? docType;
  DateTime? docDate;
  String? description;
  num? amount;
  String? requestId;

  Ledger(
    this.id,
    this.docId,
    this.docNo,
    this.docType,
    this.docDate,
    this.description,
    this.amount,
    this.requestId,
  );

  factory Ledger.fromJson(Map<String, dynamic> json) => Ledger(
        json["id"],
        json["docId"],
        json["docNo"],
        json["docType"],
        json["docDate"] == null ? null : DateTime.parse(json["docDate"]),
        json["description"],
        json["amount"],
        json["requestId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "docId": docId,
        "docNo": docNo,
        "docType": docType,
        "docDate": docDate?.toIso8601String(),
        "description": description,
        "amount": amount,
        "requestId": requestId,
      };
}
