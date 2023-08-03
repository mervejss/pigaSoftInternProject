import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/Classes/User.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:provider/provider.dart';

class KullaniciBilgileriPage extends StatefulWidget {
  @override
  State<KullaniciBilgileriPage> createState() => _KullaniciBilgileriPageState();
}

class _KullaniciBilgileriPageState extends State<KullaniciBilgileriPage> {
  List<User> users = [];
  late VeriModeli veriModeli;
  late String veri;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
    fetchMemberInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildListView(),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Column(
          children: [
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  KullaniciWidget(
                    label: "İsim Soyisim: ",
                    icerik: user.name,
                    myIcon: Icons.person_pin,
                  ),
                  SizedBox(height: 25),
                  KullaniciWidget(
                    label: "E-Posta Adresi: ",
                    icerik: user.email,
                    myIcon: Icons.email,
                  ),
                  SizedBox(height: 25),
                  KullaniciWidget(
                    label: "Telefon Numarası: ",
                    icerik: user.telephone,
                    myIcon: Icons.call,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Kullanıcı Bilgileri"),
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
    );
  }

  Future<void> fetchMemberInfo() async {
    try {
      final response = await http.get(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/memberInfo'),
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
            //print(data);
            if (data != null) {
              //print("DATA BULUNDUU !!");
              setState(() {
                users = [
                  User(
                    id: data['id'] ?? '',
                    member_code: data['member_code'] ?? '',
                    member_type: data['member_type'] ?? '',
                    identitiy: data['identitiy'] ?? '',
                    name: data['name'] ?? '',
                    second_name: data['second_name'] ?? '',
                    surname: data['surname'] ?? '',
                    telephone: data['telephone'] ?? '',
                    email: data['email'] ?? '',
                    password: data['password'] ?? '',
                    token: data['token'] ?? '',
                    createdAt: data['createdAt'] ?? '',
                  )
                ];
              });
              print("DATA BULUNDUU VE EKLENDİİİİİİİİ !!");
            }
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
}

class KullaniciWidget extends StatelessWidget {
  const KullaniciWidget({
    Key? key,
    required this.label,
    required this.icerik,
    required this.myIcon,
  }) : super(key: key);

  final String label, icerik;
  final IconData myIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(myIcon, color: Colors.pink[500]),
          SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(color: Colors.pink[500]),
          ),
          SizedBox(width: 7),
          Text(icerik),
        ],
      ),
    );
  }
}
