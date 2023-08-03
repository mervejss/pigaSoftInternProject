import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:narevim/Classes/Address.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:narevim/Classes/District.dart';
import 'package:narevim/HesabimSayfalar/AdreslerimPage.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/NavigationSayfalar/HesabimPage.dart';
import 'package:provider/provider.dart';

class AdresEklePage extends StatefulWidget {
  @override
  State<AdresEklePage> createState() => _AdresEklePageState();
}

class _AdresEklePageState extends State<AdresEklePage> {
  String selectedCity = 'İl Seçiniz',
      selectedDistrict = 'İlçe Seçiniz',
      selectedCityID = '',
      selectedDistrictID = '';

  List<District> districtList = []; // İlçe listesi
  List<String> cityList = []; // İl listesi
  late VeriModeli veriModeli;
  late String veri, ePosta;
  bool isAddressSelected = false;

  TextEditingController adTec = TextEditingController();
  TextEditingController soyadTec = TextEditingController();
  TextEditingController telefonTec = TextEditingController();
  TextEditingController adresTec = TextEditingController();

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
    ePosta = veriModeli.ePosta;
    fetchCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        child: buildListView(context),
      ),
    );
  }

  ListView buildListView(BuildContext context) {
    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "İletişim Bilgileri",
            ),
            Divider(
              color: Colors.grey,
            ),
            Row(
              children: [
                Icon(Icons.person_pin, color: Colors.pink),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: adTec,
                    decoration: buildInputDecoration(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 7),
            Row(
              children: [
                SizedBox(width: 35),
                Expanded(
                  child: TextField(
                    controller: soyadTec,
                    decoration: buildInputDecoration1(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 7),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.pink),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: buildTextInputType(),
                    controller: telefonTec,
                    decoration: InputDecoration(
                        hintText: "Telefon",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5))),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              children: [
                Icon(Icons.location_pin, size: 30, color: Colors.pink),
                SizedBox(width: 10),
                Text("Adres Bilgileri"),
              ],
            ),
            Divider(
              color: Colors.grey,
            ),
            SizedBox(
              height: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Şehir seçin"),
                GestureDetector(
                  onTap: showCitySelectionDialog,
                  child: Text(
                    selectedCity,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text("İlçe seçin"),
                GestureDetector(
                  onTap: () {
                    showDistrictSelectionDialog();
                  },
                  child: Text(
                    selectedDistrict,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.apartment, color: Colors.pink),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: adresTec,
                    decoration: buildInputDecoration2(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  style: buildButtonStyle2(),
                  onPressed: () {
                    setState(() {
                      isAddressSelected = !isAddressSelected;
                      if (isAddressSelected) {
                        // Seçildi durumunda yapılacak işlemler
                        print('fatura farklı adrese gidecek');
                      } else {
                        // Vazgeçildi durumunda yapılacak işlemler
                        print('fatura aynı adrese gidecek.');
                      }
                    });
                  },
                  child: isAddressSelected
                      ? Icon(Icons.circle_outlined)
                      : Icon(Icons.check_circle),
                ),
                SizedBox(width: 10),
                Text("Faturam aynı adrese gönderilsin"),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
                style: buildButtonStyle(),
                onPressed: () {
                  setState(() {
                    String name = adTec.text;
                    String surname = soyadTec.text;
                    String telephone = telefonTec.text;
                    String cityId = selectedCityID;
                    String townId = selectedDistrictID;
                    String clearAddress = adresTec.text;
                    fetchSaveAddress(
                        name, surname, telephone, cityId, townId, clearAddress);
                  });

                  Navigator.pop(context);
                },
                child: Text("Kaydet")),
          ],
        ),
      ],
    );
  }

  ButtonStyle buildButtonStyle2() {
    return ButtonStyle(
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

  InputDecoration buildInputDecoration2() {
    return InputDecoration(
        hintText: "Adres",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)));
  }

  TextInputType buildTextInputType() {
    return TextInputType.numberWithOptions(decimal: false, signed: false);
  }

  InputDecoration buildInputDecoration1() {
    return InputDecoration(
        hintText: "Soyad",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)));
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
        hintText: "Ad",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)));
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(
        "Adres Ekle",
      ),
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
    );
  }

  Future<bool> fetchCities() async {
    try {
      final response = await http.get(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/city'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            final data = jsonData['data'];
            if (data != null && data is List) {
              setState(() {
                cityList =
                    List<String>.from(data.map((item) => item['title'] ?? ''));
              });
            }
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

  Future<bool> fetchDistricts(String cityId) async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/town'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
        body: {
          'city_id': cityId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            final data = jsonData['data'];
            if (data != null && data is List) {
              setState(() {
                districtList = List<District>.from(data.map((item) => District(
                      title: item['title'] ?? '',
                      id: item['id'] ?? '',
                    )));
              });
            }
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

  Future<void> fetchSaveAddress(String name, String surname, String telephone,
      String cityId, String townId, String clearAddress) async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/save_address'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
        body: {
          'name': name,
          'surname': surname,
          'email': ePosta,
          'telephone': telephone,
          'city': cityId,
          'town': townId,
          'clear_address': clearAddress,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            veriModeli.showNotificationDialog(context, jsonData['message']);

            print('Address saved successfully.' + jsonData['message']);

            // Do something after saving the address
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

  void showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Şehir Seçimi'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cityList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(cityList[index]),
                  onTap: () {
                    setState(() {
                      selectedCity = cityList[index];
                      selectedCityID = (index + 1).toString();
                      //print(selectedCity);
                      //print(index+1);
                      //print((index+1).toString());
                      fetchDistricts((index + 1).toString());
                      Navigator.pop(context); // Dialog kapatılıyor
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showDistrictSelectionDialog() {
    // Seçilen şehre ait ilçe listesi

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('İlçe Seçimi'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: districtList.length,
              itemBuilder: (context, index) {
                final district = districtList[index];
                return ListTile(
                  title: Text(district.title),
                  onTap: () {
                    setState(() {
                      selectedDistrict = district.title;
                      print(district.title);
                      print(district.id);

                      selectedDistrictID = district.id;

                      Navigator.pop(context); // Dialog kapatılıyor
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  ButtonStyle buildButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return Colors.pink;
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return Colors.white;
        },
      ),
    );
  }
}
