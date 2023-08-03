import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/Classes/Bank.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:provider/provider.dart';

class HavaleEFT extends StatefulWidget {
  const HavaleEFT({Key? key}) : super(key: key);

  @override
  State<HavaleEFT> createState() => _HavaleEFTState();
}

class _HavaleEFTState extends State<HavaleEFT> {
  List<Bank> bankList = [];
  late VeriModeli veriModeli;
  late String veri;
  late Future<String> veriFuture;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veriFuture = Future.delayed(Duration(seconds: 2), () {
      return veriModeli.order_number;
    });
    fetchBanks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Havale / EFT"),
        foregroundColor: Colors.pink,
        backgroundColor: Colors.white,
      ),
      body: buildFutureBuilder(),
    );
  }

  FutureBuilder<String> buildFutureBuilder() {
    return FutureBuilder<String>(
      future: veriFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          String veri = snapshot.data ?? '';

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${snapshot.data}"),
                SizedBox(height: 15),
                Text(
                    "Sipariş numarasını açıklamaya yazarak EFT/Havale işlemini gerçekleştirebilirsiniz."),
                SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: bankList.length,
                    itemBuilder: (context, index) {
                      Bank bank = bankList[index];
                      return Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bank.title,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20)),
                            SizedBox(height: 25),
                            Text(bank.description,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> fetchBanks() async {
    try {
      final response = await http.get(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/bankList'),
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
                bankList = (jsonData['data'] as List)
                    .map((item) => Bank.fromJson(item))
                    .toList();
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
}
