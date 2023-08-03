class Basket {
  String rowid;
  String id;
  int qty;
  double price;
  double discountPrice;
  bool isDiscount;
  String name;
  String title;
  String imgUrl;
  double subTotal;
  String brand;

  Basket({
    required this.rowid,
    required this.id,
    required this.qty,
    required this.price,
    required this.discountPrice,
    required this.isDiscount,
    required this.name,
    required this.title,
    required this.imgUrl,
    required this.subTotal,
    required this.brand,
  });

  factory Basket.fromJson(Map<String, dynamic> json) {
    return Basket(
      rowid: json['rowid'] ?? '',
      id: json['id'] ?? '',
      qty: json['qty'] ?? 0,
      price: double.parse(json['price'].toString() ?? '0'),
      discountPrice: double.parse(json['discount_price'].toString() ?? '0'),
      isDiscount: json['isDiscount'] == "1",
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      imgUrl: json['img_url'] ?? '',
      subTotal: double.parse(json['subTotal'].toString() ?? '0'),
      brand: json['brand'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'title': title,
      'imgUrl': imgUrl,
      // Add other properties here...
    };
  }
}
