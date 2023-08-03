class OrderDetail {
  final String id;
  final String orderId;
  final String productId;
  final String title;
  final String size;
  final String color;
  final String qty;
  final String subtotal;
  final String total;
  final String isActive;
  final String isDeleted;
  final String createdAt;
  final String birim;
  final String kdv;
  final String imgUrl;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.title,
    required this.size,
    required this.color,
    required this.qty,
    required this.subtotal,
    required this.total,
    required this.isActive,
    required this.isDeleted,
    required this.createdAt,
    required this.birim,
    required this.kdv,
    required this.imgUrl,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      title: json['title'],
      size: json['size'],
      color: json['color'],
      qty:json['qty'],
      subtotal: json['subtotal'], // Convert to String and then parse as double
      total: json['total'],
      isActive: json['isActive'] ,
      isDeleted: json['isDeleted'] ,
      createdAt: json['createdAt'],
      birim: json['birim'],
      kdv: json['kdv'],
      imgUrl: json['img_url'],
    );
  }
}