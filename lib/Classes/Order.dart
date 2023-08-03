import 'package:narevim/Classes/OrderDetail.dart';

class Order {
  final String orderId;
  final String orderNumber;
  final String totalAmount;
  final String orderDate;
  final String memberAddress;
  final String orderState;
  final List<OrderDetail> orderDetails;

  Order({
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    required this.orderDate,
    required this.memberAddress,
    required this.orderState,
    required this.orderDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<dynamic> orderDetailJsonList = json['order_detail'];
    List<OrderDetail> orderDetails = orderDetailJsonList
        .map((orderDetailJson) => OrderDetail.fromJson(orderDetailJson))
        .toList();

    return Order(
      orderId: json['order_id'],
      orderNumber: json['order_number'],
      totalAmount: json['total_amount'].toString(),
      orderDate: json['order_date'],
      memberAddress: json['member_address'],
      orderState: json['order_state'],
      orderDetails: orderDetails,
    );
  }
}


