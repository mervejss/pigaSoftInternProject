import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/AnasayfaSayfalar/AnasayfaUrunDetayi.dart';
import 'package:narevim/Classes/Order.dart';
import 'package:narevim/Classes/OrderDetail.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:provider/provider.dart';

class SiparisDetayPage extends StatefulWidget {
  final String orderId;
  final int index;

  const SiparisDetayPage({Key? key, required this.orderId, required this.index})
      : super(key: key);

  @override
  State<SiparisDetayPage> createState() => _SiparisDetayPageState();
}

class _SiparisDetayPageState extends State<SiparisDetayPage> {
  List<OrderDetail> orderDetailList = [];
  List<Order> orderList = [];

  late VeriModeli veriModeli;

  late String veri;

  late String image_path;

  late var indx;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
    indx = widget.index;
    setState(() {
      _isLoading = true;
    });

    fetchOrderList().then((_) {
      fetchOrderDetail(widget.orderId).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsetsDirectional.all(5),
              padding: EdgeInsetsDirectional.all(15),
              decoration: buildBoxDecoration(),
              child: _isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator(), // Replace this with your loading animation
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: buildListView(),
                        ),
                      ],
                    ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsetsDirectional.all(5),
              padding: EdgeInsetsDirectional.all(15),
              decoration: buildBoxDecoration(),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 15),
                      Icon(Icons.cached_rounded, color: Colors.orange[400]),
                      SizedBox(width: 10),
                      Text("Kargo Bekleniyor",
                          style: TextStyle(color: Colors.orange[400])),
                    ],
                  ),
                  Expanded(
                    child: buildListView1(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsetsDirectional.all(5),
              padding: EdgeInsetsDirectional.all(5),
              decoration: buildBoxDecoration(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_pin, color: Colors.pink),
                      SizedBox(
                        width: 15,
                      ),
                      Text("Teslimat Adresi"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ListView buildListView1() {
    return ListView.builder(
      itemCount: orderDetailList.length,
      itemBuilder: (context, index) {
        OrderDetail orderDetail = orderDetailList[index];

        return Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AnasayfaUrunDetayi(
                                id: orderDetail.productId,
                                title: orderDetail.title,
                              )),
                    );
                  },
                  child: Image.network(
                      '${veriModeli.image_path}${orderDetail.imgUrl}',
                      height: 60,
                      width: 60),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(orderDetail.title),
                      Text('Adet :  ${orderDetail.qty}'),
                      Text('${orderDetail.subtotal} TL ',
                          style: TextStyle(color: Colors.pink)),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        );
      },
    );
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        Order order = orderList[indx];
        return Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text("Sipariş No         : "),
                Text("${order.orderNumber}",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text("Sipariş Tarihi     : "),
                Text("${order.orderDate}",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text("Sipariş Özeti      : "),
                Text("${order.orderDetails.length} Ürün",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text("Sipariş Toplam  : "),
                Text("${order.totalAmount} TL ",
                    style: TextStyle(color: Colors.pink)),
              ],
            ),
          ],
        );
      },
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8), // Set the border radius here
      border: Border.all(color: Colors.grey[300]!), // Add a border
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Sipariş Detayı"),
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
    );
  }

  Future<void> fetchOrderDetail(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/orderDetail'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
        body: {
          'order_id': orderId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            final data = jsonData['data'];

            if (data != null && data is List) {
              setState(() {
                orderDetailList = List<OrderDetail>.from(
                    data.map((item) => OrderDetail.fromJson(item)));
              });
            }
          }
        } else {
          print('Invalid JSON data');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: ${error.toString()}');
    }
  }

  Future<void> fetchOrderList() async {
    try {
      final response = await http.get(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/orders'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            final data = jsonData['data'];

            if (data != null && data is List) {
              setState(() {
                setState(() {
                  image_path = jsonData['image_path'];
                  veriModeli.image_path = image_path;
                });
                orderList =
                    List<Order>.from(data.map((item) => Order.fromJson(item)));
              });
            }
            print(jsonData['message']);
          } else {
            print('Invalid JSON data');
          }
        } else {
          print('Invalid JSON data');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: ${error.toString()}');
    }
  }
}
