class ProductDetailData {
  final String id;
  final String url;
  final String code_url;
  final String code;
  final String title;
  final String description;
  final String price;
  final String discount_price;
  final String stock;

  ProductDetailData({
    required this.id,
    required this.url,
    required this.code_url,
    required this.code,
    required this.title,
    required this.description,
    required this.price,
    required this.discount_price,
    required this.stock,
  });

  factory ProductDetailData.fromJson(Map<String, dynamic> json) {
    return ProductDetailData(
      id: json['id'],
      url: json['url'],
      code_url: json['code_url'],
      code: json['code'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      discount_price: json['discount_price'],
      stock: json['stock'],
    );
  }
}