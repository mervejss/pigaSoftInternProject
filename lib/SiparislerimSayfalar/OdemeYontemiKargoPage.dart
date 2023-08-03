import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/SiparislerimSayfalar/HavaleEFT.dart';
import 'package:narevim/SiparislerimSayfalar/KapidaOdeme.dart';
import 'package:narevim/SiparislerimSayfalar/KrediKarti.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OdemeYontemiKargoPage extends StatefulWidget {
  const OdemeYontemiKargoPage({Key? key}) : super(key: key);

  @override
  State<OdemeYontemiKargoPage> createState() => _OdemeYontemiKargoPageState();
}

class _OdemeYontemiKargoPageState extends State<OdemeYontemiKargoPage> {
  TextEditingController kuponKoduTec = TextEditingController();
  TextEditingController tecOrder_note = TextEditingController();

  String selectedOption = "Kredi Kartı";
  late VeriModeli veriModeli;
  late String veri;
  String order_note = '', payment_type = '0';
  //payment_type : 0 ise kredi karti, 1 kapıda ödeme , 2 havale

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildSingleChildScrollView(context),
    );
  }

  SingleChildScrollView buildSingleChildScrollView(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsetsDirectional.all(15),
        margin: EdgeInsetsDirectional.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Ödeme Yöntemini Seçin : "),
            ElevatedButton(
              style: buildButtonStyle2(),
              onPressed: () async {
                String? selected = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return buildSimpleDialog(context);
                  },
                );

                if (selected != null) {
                  setState(() {
                    selectedOption = selected;
                  });
                }
              },
              child: Text(selectedOption),
            ),
            SizedBox(height: 50),
            Text("Kargo Firması Seçin : "),
            ElevatedButton(
                style: buildButtonStyle2(),
                onPressed: () {},
                child: Text("UPS Kargo")),
            buildSizedBox(),
            Text("Kupon Kodu Ekle",
                style: TextStyle(fontWeight: FontWeight.bold)),
            buildSizedBox(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: kuponKoduTec,
                    decoration: buildInputDecoration("Kupon Kodu"),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: buildButtonStyle(),
                  onPressed: () {
                    couponControl(kuponKoduTec.text);
                  },
                  child: Text("Uygula"),
                ),
              ],
            ),
            buildSizedBox(),
            Text("Eklemek istediğiniz not var mı ?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            buildSizedBox(),
            TextField(
              controller: tecOrder_note,
              decoration: buildInputDecoration("Not"),
            ),
            buildSizedBox(),
            buildElevatedButton(context),
          ],
        ),
      ),
    );
  }

  SizedBox buildSizedBox() => SizedBox(height: 20);

  ElevatedButton buildElevatedButton(BuildContext context) {
    return ElevatedButton(
        style: buildButtonStyle(),
        onPressed: () {
          print(selectedOption);
          order_note = tecOrder_note.text;

          if (selectedOption == "Kredi Kartı") {
            payment_type = "0";
            createOrder();
            veriModeli.urunSayisi = 0;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => KrediKarti()),
              ModalRoute.withName(
                  '/anasayfa'), // Burada '/anasayfa' AnasayfaPage'in rotasına denk gelmelidir.
            );
          } else if (selectedOption == "Kapıda Ödeme") {
            payment_type = "1";
            createOrder();

            veriModeli.urunSayisi = 0;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => KapidaOdeme()),
              ModalRoute.withName(
                  '/anasayfa'), // Burada '/anasayfa' AnasayfaPage'in rotasına denk gelmelidir.
            );
          } else if (selectedOption == "Havale / EFT") {
            payment_type = "2";
            createOrder();

            veriModeli.urunSayisi = 0;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HavaleEFT()),
              ModalRoute.withName(
                  '/anasayfa'), // Burada '/anasayfa' AnasayfaPage'in rotasına denk gelmelidir.
            );
          }
        },
        child: Text("Ödeme Ekranı"));
  }

  SimpleDialog buildSimpleDialog(BuildContext context) {
    return SimpleDialog(
      title: Text("Ödeme Yöntemini Seçin"),
      children: [
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, "Kredi Kartı");
          },
          child: Text("Kredi Kartı"),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, "Kapıda Ödeme");
          },
          child: Text("Kapıda Ödeme"),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, "Havale / EFT");
          },
          child: Text("Havale / EFT"),
        ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Ödeme Yöntemi - Kargo "),
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
    );
  }

  Future<void> createOrder() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/createOrder'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
        body: {
          'payment_type': payment_type,
          'cargo_id': "1",
          'order_note': order_note,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            veriModeli.showNotificationDialog(context, jsonData['message']);
            setState(() {
              veriModeli.order_number = jsonData['order_number'];
            });
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

  Future<void> couponControl(String kuponKodu) async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/couponControl'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
        body: {
          'discount_code': kuponKodu,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {}
          veriModeli.showNotificationDialog(
              context, "Böyle bir kupon bulunamadı !");
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

  ButtonStyle buildButtonStyle2() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      side: MaterialStateProperty.all<BorderSide>(
        BorderSide(color: Colors.pink, width: 2),
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(),
        ),
      ),
    );
  }

  ButtonStyle buildButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.pink),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    );
  }

  InputDecoration buildInputDecoration(String icerik) {
    return InputDecoration(
      hintText: "$icerik",
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.pink),
        borderRadius: BorderRadius.circular(8),
      ),
      border: OutlineInputBorder(
        borderSide:
            BorderSide(color: Colors.pink), // Use pink border for other states
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      isDense: true, // Reduce the height of the TextField
    );
  }
}
