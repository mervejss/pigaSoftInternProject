import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:narevim/HesabimSayfalar/AdreslerimPage.dart';
import 'package:narevim/HesabimSayfalar/FavorilerimPage.dart';
import 'package:narevim/HesabimSayfalar/KullaniciBilgileriPage.dart';
import 'package:narevim/HesabimSayfalar/SifreDegistirPage.dart';
import 'package:narevim/HesabimSayfalar/SiparislerimPage.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/NavigationSayfalar/GirisYapPage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HesabimPage extends StatefulWidget {
  const HesabimPage({Key? key}) : super(key: key);

  @override
  State<HesabimPage> createState() => _HesabimPageState();
}

class _HesabimPageState extends State<HesabimPage> {
  final _storage = const FlutterSecureStorage();
  late VeriModeli veriModeli;
  late String veri;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Container(
        margin: EdgeInsets.all(25),
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 2,
            ),
            veriModeli.buildImage(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SiparislerimPage()),
                );
              },
              child: buildRowWithIconsAndLabel(Icons.history, "Siparişlerim"),
            ),
            buildDivider(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavorilerimPage()),
                );
              },
              child: buildRowWithIconsAndLabel(Icons.favorite, "Favorilerim"),
            ),
            buildDivider(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdreslerimPage()),
                );
              },
              child:
                  buildRowWithIconsAndLabel(Icons.location_pin, "Adreslerim"),
            ),
            buildDivider(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KullaniciBilgileriPage()),
                );
              },
              child: buildRowWithIconsAndLabel(
                  Icons.person_rounded, "Kullanıcı Bilgileri"),
            ),
            buildDivider(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SifreDegistirPage()),
                );
              },
              child: buildRowWithIconsAndLabel(
                  Icons.swap_horiz_rounded, "Şifre Değiştir"),
            ),
            buildDivider(),
            InkWell(
              onTap: () async {
                try {
                  bool isSuccess = await fetchCikis();
                  if (isSuccess) {
                    print("ÇIKIŞ BAŞARILI");

                    setState(() {
                      _storage.deleteAll();
                      late VeriModeli veriModeli;
                      veriModeli =
                          Provider.of<VeriModeli>(context, listen: false);
                    });

                    Navigator.pop(
                      context,
                      MaterialPageRoute(builder: (context) => GirisYapPage()),
                    );
                  } else {
                    print("ÇIKIŞ BAŞARISIZ");
                  }
                } catch (e) {
                  print('Error: ${e.toString()}');
                }
              },
              child: buildRowWithIconsAndLabel(
                  Icons.exit_to_app_sharp, "Çıkış Yap"),
            ),
            buildDivider(),
          ],
        ),
      ),
    );
  }



  Future<bool> fetchCikis() async {
    try {
      final response = await http.get(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/logout'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            print(jsonData['message']);
            return true; // Başarılı
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

    return false; // Başarısız
  }

  Row buildRowWithIconsAndLabel(IconData icon, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon),
        Text(label),
        Icon(Icons.arrow_circle_right_outlined),
      ],
    );
  }
  Divider buildDivider() {
    return Divider(
      color: Colors.grey,
      height: 5,
    );
  }
  AppBar buildAppBar() {
    return AppBar(
      title: Text(
        "Hesabım",
      ),
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
    );
  }
}
