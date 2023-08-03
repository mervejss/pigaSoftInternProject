import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/Classes/Category.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:provider/provider.dart';

import '../kategoriSayfalar/FirstCategoriesPage.dart';



class KategorilerPage extends StatefulWidget {
  @override
  State<KategorilerPage> createState() => _KategorilerPageState();
}

class _KategorilerPageState extends State<KategorilerPage> {
  List<Category> categories = [];
  late VeriModeli veriModeli;
  late String veri;

  final String
      imageBaseUrl =
      "http://eticaret.demo.pigasoft.com/panel/uploads/product_first_group_v/",
      secondImageBaseUrl =
      "https://www.demo.pigasoft.com/eticaret/panel/uploads/product_second_group_v/350x216/";


  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    fetchCategories();
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
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Column(
          children: [
            buildContainer(),
            SizedBox(height: 5, width: 2),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FirstCategoriesPage(category: category, first_category_id: category.id,)),
                );

                },
              child: ListTile(
                leading: Image.network('$imageBaseUrl${category.img_url}'),
                title: Text(category.title),
              ),
            ),
            Divider(color: Colors.grey),
          ],
        );
      },


    );
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/firstCategories'),
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
                categories = List<Category>.from(data.map((item) => Category(
                  id: item['id'] ?? '',
                  url: item['url'] ?? '',
                  title: item['title'] ?? '',
                  description: item['description'] ?? '',
                  img_url: item['img_url'] ?? '',
                  banner_url: item['banner_url'] ?? '',
                  home_banner_url: item['home_banner_url'] ?? '',
                  isNext: item['isNext'] ?? false,
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

  Container buildContainer() {
    return Container(
              height: 1.7,
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 1),
            );
  }

  AppBar buildAppBar() {
    return AppBar(

      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        'Kategoriler',
        style: TextStyle(color: Colors.pink[500]),
      ),
    );
  }


}
