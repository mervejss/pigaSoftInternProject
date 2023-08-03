import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:narevim/AnasayfaSayfalar/AnasayfaUrunDetayi.dart';
import 'package:narevim/Classes/Basket.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/HesabimSayfalar/AdreslerimPage.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:provider/provider.dart';

class SepetimPage extends StatefulWidget {
  @override
  State<SepetimPage> createState() => _SepetimPageState();
}

class _SepetimPageState extends State<SepetimPage> {
  late VeriModeli veriModeli;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    setState(() {
      veriModeli.urunSayisi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.pink[500],
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Sepet : ${veriModeli.urunSayisi} ürün",
              style: TextStyle(
                  color: Colors.pink[500], fontWeight: FontWeight.w300)),
          centerTitle: true,
        ),
        body: Iskelet(),
      ),
    );
  }
}

class Iskelet extends StatefulWidget {
  @override
  State<Iskelet> createState() => _IskeletState();
}

class _IskeletState extends State<Iskelet> {
  List<Basket> baskets = [];
  late VeriModeli veriModeli;
  late String veri, tutar = "";

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
    fetchGetBasket();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Divider(color: Colors.grey),
            Expanded(
              child: buildListView(),
            ),
            Row(
              children: [
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Sepet Toplam",
                  style: buildTextStyle(),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("$tutar  TL ", style: TextStyle(color: Colors.pink[500])),
                SizedBox(
                  width: 150,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (veriModeli.urunSayisi == 0) {
                      veriModeli.showNotificationDialog(context,
                          "Sepetinizde ürün bulunamadı ! Lütfen ürün ekleyin.");
                    } else {
                      veriModeli.showNotificationDialog(context,
                          "Siparişinizin teslim edileceği adresi seçiniz.");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdreslerimPage()),
                      );
                    }
                  },
                  child: Text("Alışverişi Tamamla"),
                  style: buildButtonStyle(),
                )
              ],
            ),
            Divider(color: Colors.grey),
          ],
        ));
  }

  Future<void> fetchGetBasket() async {
    try {
      final response = await http.get(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/getBasket'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=${veri}',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            final data = jsonData['data'];
            print(data);

            if (data != null && data is List) {
              setState(() {
                baskets = List<Basket>.from(data.map((item) {
                  item['subTotal'] =
                      double.parse(removeCommas(item['subTotal']));
                  return Basket.fromJson(item);
                }));
                tutar = removeCommas(jsonData['total']);
                veriModeli.totalTL = tutar;

                veriModeli.urunSayisi = baskets.length;
              });
            }
            print(jsonData['message']);
          }
          print(jsonData['message']);
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

  Future<void> fetchUpdateBasket(String rowID, String qty) async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/updateCart'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
        body: {
          'rowID': rowID,
          'qty': qty,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            fetchGetBasket();
            print(jsonData['message']);
          }
          print(jsonData['message']);
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

  Future<void> updateDataAndRefresh() async {
    await fetchGetBasket();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SepetimPage()),
    );
  }

  Future<void> fetchRemoveBasket(String rowID) async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/removeFromCart'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
        body: {
          'rowID': rowID,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            veriModeli.showNotificationDialog(context, jsonData['message']);
            print(jsonData['message']);

            await updateDataAndRefresh();
          }
          print(jsonData['message']);
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

  String removeCommas(String value) {
    return value.replaceAll(',', '');
  }

  ButtonStyle buildButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
          Colors.pink), // Buton arkaplan rengi olarak pembe kullanılıyor.
    );
  }

  TextStyle buildTextStyle() {
    return TextStyle(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500);
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: baskets.length,
      itemBuilder: (context, index) {
        final basket = baskets[index];
        return Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AnasayfaUrunDetayi(
                            id: basket.id,
                            title: basket.title,
                          )),
                );
              },
              child: ListTile(
                leading: Image.network(basket.imgUrl),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(basket.brand,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Narevim",
                                    style: TextStyle(color: Colors.black)),
                                content: Text(
                                    "Silmek istediğinize emin misiniz?",
                                    style: TextStyle(color: Colors.black)),
                                actions: [
                                  // SIL button

                                  // HAYIR button
                                  TextButton(
                                    onPressed: () {
                                      // Close the dialog
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("HAYIR",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Close the dialog
                                      Navigator.of(context).pop();
                                      // Perform delete operation
                                      setState(() {
                                        fetchRemoveBasket(basket.rowid);
                                        //veriModeli.urunSayisi -= basket.qty;
                                        fetchUpdateBasket(
                                            basket.rowid, (0).toString());
                                        fetchGetBasket();
                                      });
                                    },
                                    child: Text("SİL",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        iconSize: 30,
                      ),
                    ]),
                    Row(
                      children: [
                        Expanded(child: Text(basket.title, style: TextStyle())),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 5,
              height: 15,
            ),
            Row(
              children: [
                SizedBox(
                  width: 65,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.pink,
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        fetchUpdateBasket(
                            basket.rowid, ((basket.qty) - 1).toString());
                        fetchGetBasket();
                      });
                    },
                    icon: Icon(Icons.remove),
                    color: Colors.white,
                    iconSize: 20,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        5), // Sets the rounded corner radius
                    color: Colors.grey[400],
                  ),
                  child: Center(
                    child: Text(
                      basket.qty.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  height: 45,
                  width: 45,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        10), // Sets the rounded corner radius
                    color: Colors.pink,
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        fetchUpdateBasket(
                            basket.rowid, ((basket.qty) + 1).toString());
                        fetchGetBasket();
                      });
                    },
                    icon: Icon(Icons.add),
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                Text(
                  "${basket.subTotal} TL",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
              ],
            ),
            Divider(color: Colors.grey),
          ],
        );
      },
    );
  }
}
