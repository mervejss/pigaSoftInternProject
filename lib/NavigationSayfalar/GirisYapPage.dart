import 'package:flutter/material.dart';
import 'package:narevim/Classes/EmailProvider.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/NavigationSayfalar/HesabimPage.dart';
import 'package:narevim/NavigationSayfalar/KayitOlPage.dart';
import 'package:narevim/NavigationSayfalar/SifremiUnuttumPage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class GirisYapPage extends StatefulWidget {
  @override
  State<GirisYapPage> createState() => _GirisYapPageState();
}

class _GirisYapPageState extends State<GirisYapPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: Scaffold(
        body: Iskelet(),
      ),
    );
  }
}

class Iskelet extends StatefulWidget {
  const Iskelet({Key? key}) : super(key: key);

  @override
  State<Iskelet> createState() => _IskeletState();
}

class _IskeletState extends State<Iskelet> {
  final _storage = const FlutterSecureStorage();
  late VeriModeli veriModeli;
  late String veri;
  TextEditingController ePostaTec = TextEditingController();
  TextEditingController sifreTec = TextEditingController();

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
    _autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => EmailProvider(),
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: ListView(
            children: [
              buildImage(),
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
                              controller: ePostaTec,
                              decoration: buildInputDecoration())),
                    ),
                  ],
                ),
              ),
              Consumer<EmailProvider>(
                builder: (context, emailProvider, child) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      children: [
                        Icon(Icons.key_sharp, color: Colors.pink[500]),
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: buildBoxDecoration(),
                            child: TextField(
                              controller: sifreTec,
                              obscureText:
                                  true, // Şifrenin gizli olarak gösterilmesini sağlar
                              decoration: buildInputDecoration1(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.only(left: 35, right: 15),
                child: ElevatedButton(
                    style: buildButtonStyle(),
                    onPressed: () async {
                      try {
                        bool isSuccess = await fetchGiris();
                        if (isSuccess) {
                          print("BAŞARILI");
                          await _saveCredentials(ePostaTec.text, sifreTec.text);
                        } else {
                          // Giriş başarısız, hata mesajını gösterebilirsiniz
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.grey[800],
                                title: Text("Narevim",
                                    style: TextStyle(color: Colors.black)),
                                content: Text(
                                  "Geçerli bir Email adresi veya şifre girin.",
                                  style: TextStyle(color: Colors.white),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("OK",
                                        style: TextStyle(color: Colors.black)),
                                    style: buildButtonStyle2(),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } catch (e) {
                        print('Error: ${e.toString()}');
                      }
                    },
                    child: Text("Giriş Yap")),
              ),
              Padding(
                padding: EdgeInsets.only(left: 35, right: 15),
                child: ElevatedButton(
                    style: buildButtonStyle1(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => KayitOlPage()),
                      );
                    },
                    child: Text(
                      "Kayıt Ol",
                      style: TextStyle(
                        color: Colors.pink[500],
                      ),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(left: 35, right: 15, top: 12),
                child: InkWell(
                    child: Text("Şifremi Unuttum"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SifremiUnuttumPage()),
                      );
                    }),
              ),
            ],
          ),
        ));
  }
  Future<bool> fetchGiris() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/login'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
        body: {
          'email': ePostaTec.text,
          'password': sifreTec.text,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            veriModeli = Provider.of<VeriModeli>(context, listen: false);
            veriModeli.setVeri(jsonData['sessionid']);
            veriModeli.setEposta(ePostaTec.text);
            print("BAŞARIYLA GİRİŞ YAPILDI !");

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HesabimPage()),
            );

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

  Future<void> _saveCredentials(String email, String password) async {
    final _storage = const FlutterSecureStorage();
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'password', value: password);
  }

  Future<Map<String, String>?> _getCredentials() async {
    final _storage = const FlutterSecureStorage();
    final email = await _storage.read(key: 'email');
    final password = await _storage.read(key: 'password');

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }

    return null;
  }

  Future<void> _autoLogin() async {
    final credentials = await _getCredentials();
    if (credentials != null) {
      ePostaTec.text = credentials['email']!;
      sifreTec.text = credentials['password']!;

      await fetchGiris();
    }
  }

  ButtonStyle buildButtonStyle1() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.white;
          }
          return Colors.white;
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

  ButtonStyle buildButtonStyle2() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.grey[800];
          }
          return Colors.grey[800];
        },
      ),
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

  InputDecoration buildInputDecoration1() {
    return InputDecoration(
      border: InputBorder.none,
      hintText: 'Şifre',
      hintStyle: TextStyle(color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 15.0,
      ),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.grey),
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
        border: InputBorder.none,
        hintText: 'E-Posta',
        hintStyle: TextStyle(color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 15.0,
        ));
  }

  Image buildImage() {
    return Image.asset(
      'assets/narlogo.jpg',
      width: 250,
      height: 150,
      color: Colors.pink[500],
    );
  }


}
