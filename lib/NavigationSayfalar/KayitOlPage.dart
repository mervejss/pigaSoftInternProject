import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/NavigationSayfalar/GirisYapPage.dart';
import 'package:provider/provider.dart';

class KayitOlPage extends StatefulWidget {
  @override
  State<KayitOlPage> createState() => _KayitOlPageState();
}

class _KayitOlPageState extends State<KayitOlPage> {
  late VeriModeli veriModeli;
  late String veri;

  TextEditingController ad = TextEditingController();
  TextEditingController soyAd = TextEditingController();
  TextEditingController telefon = TextEditingController();
  TextEditingController eposta = TextEditingController();
  TextEditingController sifre = TextEditingController();

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.pink,
        iconTheme: IconThemeData(color: Colors.pink[500]),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Kayıt Ol'),
          foregroundColor: Colors.pink,
          backgroundColor: Colors.white,
        ),
        body: buildSingleChildScrollView(context),
      ),
    );
  }

  SingleChildScrollView buildSingleChildScrollView(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildCard(),
          SizedBox(height: 20.0),
          buildCard2(),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              fetchKayit().then((_) {
                setState(() {});
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GirisYapPage()),
                );
              });
            },
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Card buildCard2() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info),
                SizedBox(width: 10.0),
                Text(
                  'E-Posta & Şifre',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey),
            SizedBox(height: 10.0),
            Row(
              children: [
                Icon(Icons.email),
                SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    controller: eposta,
                    decoration: buildInputDecoration(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Icon(Icons.security),
                SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    controller: sifre,
                    decoration: buildInputDecoration2(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration2() {
    return InputDecoration(
      hintText: 'Şifre',
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.pink,
          width: 1.0,
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
      hintText: 'E-Posta',
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.pink,
          width: 1.0,
        ),
      ),
    );
  }

  Card buildCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İletişim Bilgileri',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            Divider(color: Colors.grey),
            SizedBox(height: 10.0),
            Row(
              children: [
                Icon(Icons.person_pin_rounded),
                SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    controller: ad,
                    decoration: InputDecoration(
                      hintText: 'Ad',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.pink,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                SizedBox(width: 34.0),
                Expanded(
                  child: TextField(
                    controller: soyAd,
                    decoration: InputDecoration(
                      hintText: 'Soyad',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.pink,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Icon(Icons.phone),
                SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    controller: telefon,
                    decoration: InputDecoration(
                      hintText: 'Telefon',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.pink,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchKayit() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/register'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
        body: {
          'email': eposta.text,
          'password': sifre.text,
          'telephone': telefon.text,
          'name': ad.text,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            print("BAŞARIYLA KAYIT OLUNDU !");
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
