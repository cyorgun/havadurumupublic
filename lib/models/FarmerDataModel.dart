import 'CityModel.dart';

class FarmerDataModel {
  final List<ProductModel> products;
  final List<CityModel> locations;

  FarmerDataModel({required this.products, required this.locations});

  Map<String, dynamic> toMap() {
    return {
      "products": products.map((e) => e.toMap()).toList(),
      "locations": locations.map((e) => e.toMap()).toList(),
    };
  }
}

class ProductModel {
  final String product;
  final int tonnage;

  ProductModel({required this.product, required this.tonnage});

  // Firestore'a uygun formatta Map'e çevirme
  Map<String, dynamic> toMap() {
    return {
      "product": product,
      "tonnage": tonnage,
    };
  }
}
