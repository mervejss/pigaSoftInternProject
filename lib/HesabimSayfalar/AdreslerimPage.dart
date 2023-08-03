import 'package:flutter/material.dart';
import 'package:narevim/Classes/Address.dart';
import 'package:narevim/HesabimSayfalar/AdresEklePage.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/SiparislerimSayfalar/OdemeYontemiKargoPage.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

class AdreslerimPage extends StatefulWidget {
  @override
  State<AdreslerimPage> createState() => _AdreslerimPageState();
}

class _AdreslerimPageState extends State<AdreslerimPage> {
  List<Address> addressList = [];
  late VeriModeli veriModeli;
  late String veri;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
    fetchAddressList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adreslerim"),
        foregroundColor: Colors.pink,
        backgroundColor: Colors.white,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdresEklePage(),
                ),
              ).then((_) {
                fetchAddressList();
              });
            },
            style: buildButtonStyle(),
            child: Text(
              "Adres Ekle",
              style: TextStyle(fontSize: 11),
            ),
          )
        ],
      ),
      body: buildListView(),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: addressList.length,
      itemBuilder: (context, index) {
        final address = addressList[index];
        return Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OdemeYontemiKargoPage()),
                );
              },
              child: Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.pink),
                              SizedBox(width: 10),
                              Text(
                                '${address.city} - ${address.town}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 34),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 15),
                                Text(
                                  address.clear_address,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                Text(address.telephone),
                                SizedBox(height: 5),
                                Text('${address.name} ${address.surname}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: buildIconButton(context, address),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconButton buildIconButton(BuildContext context, Address address) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Narevim"),
              content: Text("Silmek İstediğinize Emin Misiniz ?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("İPTAL"),
                ),
                TextButton(
                  onPressed: () {
                    // setState ile veri değişikliğini güncelle
                    setState(() {
                      print(address.id);
                      removeAddress(address.id);
                      //addressList.removeAt(index-1);
                    });
                    Navigator.pop(context);
                  },
                  child: Text("EVET SİL"),
                ),
              ],
            );
          },
        );
      },
      icon: Icon(Icons.delete_sweep_sharp, color: Colors.pink),
    );
  }

  Future<void> fetchAddressList() async {
    try {
      final response = await http.get(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/address'),
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
              print("DATA BULUNDUUUUUU ! ");
              setState(() {
                addressList = List<Address>.from(data.map((item) => Address(
                      id: item['id'] ?? '',
                      name: item['name'] ?? '',
                      surname: item['surname'] ?? '',
                      email: item['email'] ?? '',
                      telephone: item['telephone'] ?? '',
                      clear_address: item['clear_address'] ?? '',
                      city_id: item['city_id'] ?? '',
                      town_id: item['town_id'] ?? '',
                      city: item['city'] ?? '',
                      town: item['town'] ?? '',
                    )));
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

  Future<void> removeAddress(String removeID) async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/removeAddress'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
        body: {
          'address_id': removeID,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            setState(() {
              print("VERİ BULUNDU ve silindi !!");
              fetchAddressList(); // Veri değişti, güncellemek için fetchAddressList'i tekrar çağır
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

  ButtonStyle buildButtonStyle() {
    return ButtonStyle(
      shadowColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.pink;
          }
          return Colors.white;
        },
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return Colors.white;
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return Colors.pink;
        },
      ),
    );
  }
}
