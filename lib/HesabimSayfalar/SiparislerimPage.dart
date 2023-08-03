import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/AnasayfaSayfalar/AnasayfaUrunDetayi.dart';
import 'package:narevim/Classes/Favoritte.dart';
import 'package:narevim/Classes/Order.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/SiparislerimSayfalar/SiparisDetayPage.dart';
import 'package:provider/provider.dart';

class SiparislerimPage extends StatefulWidget {
  @override
  State<SiparislerimPage> createState() => _SiparislerimPageState();
}

class _SiparislerimPageState extends State<SiparislerimPage> {
  List<Order> orderList = [];
  late VeriModeli veriModeli;
  late String veri;
  late String image_path;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
    fetchOrderList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Container(
        decoration: buildBoxDecoration(),
        child: buildListView(),
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: orderList.length,
      itemBuilder: (context, index) {
        Order order = orderList[index];

        return Card(
          margin: EdgeInsetsDirectional.all(10),
          child: Container(
            margin: EdgeInsetsDirectional.all(5),
            padding: EdgeInsetsDirectional.all(5),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('${order.orderDate}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Toplam : '),
                    Text('${order.totalAmount} TL ',
                        style: TextStyle(color: Colors.pink)),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SiparisDetayPage(
                                  orderId: order.orderId, index: index)),
                        );
                      },
                      child: Text("Detaylar",
                          style: TextStyle(color: Colors.pink)),
                    )
                  ],
                ),
                Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 15),
                    Icon(Icons.cached_rounded, color: Colors.orange[400]),
                    SizedBox(width: 10),
                    Text("Kargo Bekleniyor",
                        style: TextStyle(color: Colors.orange[400])),
                  ],
                ),
                SizedBox(height: 15),
                buildListView2(order),
              ],
            ),
          ),
        );
      },
    );
  }

  ListView buildListView2(Order order) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: order.orderDetails.length,
      itemBuilder: (context, index2) {
        return Row(
          children: [
            SizedBox(width: 15),
            InkWell(
              child: Image.network(
                '$image_path${order.orderDetails[index2].imgUrl}',
                height: 45,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AnasayfaUrunDetayi(
                          id: order.orderDetails[index2].productId,
                          title: order.orderDetails[index2].title)),
                );
              },
            ),
          ],
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 10),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.purple, Colors.pinkAccent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Siparişlerim"),
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
    );
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
