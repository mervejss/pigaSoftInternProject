import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/NavigationSayfalar/SifremiUnuttumPage.dart';
import 'package:provider/provider.dart';

class SifremiUnuttumPage2 extends StatefulWidget {
  final String eposta;
  const SifremiUnuttumPage2({Key? key, required this.eposta}) : super(key: key);

  @override
  State<SifremiUnuttumPage2> createState() => _SifremiUnuttumPage2State();
}

class _SifremiUnuttumPage2State extends State<SifremiUnuttumPage2> {
  late VeriModeli veriModeli;
  late String veri;
  TextEditingController tokenTec = TextEditingController();

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
        padding: EdgeInsets.all(20.0),
        child: buildListView(context),
      ),
    );
  }

  ListView buildListView(BuildContext context) {
    return ListView(children: [
      veriModeli.buildImage(),
      SizedBox(
        height: 20,
      ),
      Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.pink[500]),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Container(
                  decoration: buildBoxDecoration(),
                  child: TextField(
                      controller: tokenTec,
                      decoration: buildInputDecoration())),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 35, right: 15),
        child: ElevatedButton(
            style: buildButtonStyle(),
            onPressed: () async {
              try {
                bool isSuccess = await fetchPasswordRecovery();
                if (isSuccess) {
                  print("BAŞARILI");
                } else {
                  // Giriş başarısız, hata mesajını gösterebilirsiniz
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return buildAlertDialog(context);
                    },
                  );
                }
              } catch (e) {
                print('Error: ${e.toString()}');
              }
            },
            child: Text(
              "Şifreyi Sıfırla",
              style: TextStyle(
                color: Colors.white,
              ),
            )),
      ),
    ]);
  }

  Future<bool> fetchPasswordRecovery() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/passwordRecovery'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
        body: {
          'email': widget.eposta,
          'token': tokenTec.text,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            print(jsonData['message']);
            return true; // Başarılı giriş
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

    return false; // Başarısız giriş
  }

  AlertDialog buildAlertDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[800],
      title: Text("Narevim", style: TextStyle(color: Colors.black)),
      content: Text(
        "Lütfen kodu tekrar deneyin",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("OK", style: TextStyle(color: Colors.black)),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.grey[800];
                }
                return Colors.grey[800];
              },
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle buildButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.pink;
          }
          return Colors.pink;
        },
      ),
      side: MaterialStateProperty.resolveWith<BorderSide>(
        (states) {
          return BorderSide(
            color: Colors.pink,
            width: 1.0,
          );
        },
      ),
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
        border: InputBorder.none,
        hintText: 'Sms ile gelen kodu giriniz..',
        hintStyle: TextStyle(color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 15.0,
        ));
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.grey),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(
        "Şifremi Unuttum",
        style: TextStyle(
          color: Colors.pink, // Yazı rengi
        ),
      ),
      backgroundColor: Colors.white, // Arka plan rengi
      foregroundColor: Colors.pink, // Icon ve action butonları rengi
    );
  }
}
