class Brand {
  String id;
  String title;
  String price;
  String discountPrice;
  String imgUrl;
  bool isDiscount;
  String brand;

  Brand({
    required this.id,
    required this.title,
    required this.price,
    required this.discountPrice,
    required this.imgUrl,
    required this.isDiscount,
    required this.brand,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      discountPrice: json['discount_price'] ?? '',
      imgUrl: json['img_url'] ?? '',
      isDiscount: json['isDiscount'] == '1',
      brand: json['brand'] ?? '',
    );
  }
}
