import 'package:hive/hive.dart';
part 'models.g.dart';

@HiveType(typeId: 0)
class Customer {
  @HiveField(0)
  int id;
  @HiveField(1)
  int companyId;
  @HiveField(2)
  int refId;
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
  double? balance;
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
