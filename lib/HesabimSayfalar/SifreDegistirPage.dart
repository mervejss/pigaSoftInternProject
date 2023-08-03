import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SifreDegistirPage extends StatefulWidget {
  @override
  _SifreDegistirPageState createState() => _SifreDegistirPageState();
}

class _SifreDegistirPageState extends State<SifreDegistirPage> {
  TextEditingController eskiSifreTec = TextEditingController();
  TextEditingController yeniSifreTec = TextEditingController();

  late VeriModeli veriModeli;
  late String veri;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Şifremi Değiştir"),
        foregroundColor: Colors.pink,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: buildListView(),
      ),
    );
  }

  ListView buildListView() {
    return ListView(
      children: [
        veriModeli.buildImage(),
        buildRow(Icon(Icons.key_off), eskiSifreTec, "Eski Şifre"),
        buildSizedBox(),
        buildRow(Icon(Icons.key), yeniSifreTec, "Yeni Şifre"),
        buildSizedBox(),
        Padding(
          padding: EdgeInsets.only(left: 40),
          child: ElevatedButton(
              onPressed: () {
                changePassword();
              },
              child: Text("Şifreyi Değiştir"),
              style: buildButtonStyle()),
        ),
      ],
    );
  }

  ButtonStyle buildButtonStyle() {
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
      (states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.pink[500];
        }
        return Colors.pink;
      },
    ));
  }

  SizedBox buildSizedBox() {
    return SizedBox(
      width: 25,
      height: 25,
    );
  }

  Future<void> changePassword() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/changePassword'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
        body: {
          'old_password': eskiSifreTec.text,
          'new_password': yeniSifreTec.text,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            print('ŞİFRE BAŞARIYLA DEĞİŞTİRİLDİ !!!!! ' + jsonData['message']);
          } else {
            print(jsonData['message']);
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

  Row buildRow(var icon, var controller, var text) {
    return Row(
      children: [
        icon,
        SizedBox(width: 15),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: Colors.pink,
              ),
            ),
            child: TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15),
                hintText: text,
                border: InputBorder.none,
              ),
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}
