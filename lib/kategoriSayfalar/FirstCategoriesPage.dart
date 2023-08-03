import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:narevim/Classes/Category.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/kategoriSayfalar/SecondCategoriesPage.dart';
import 'package:provider/provider.dart';

class FirstCategoriesPage extends StatefulWidget {
  final Category category;
  var first_category_id;

  FirstCategoriesPage(
      {required this.category, required this.first_category_id});

  @override
  State<FirstCategoriesPage> createState() => _FirstCategoriesPageState();
}

class _FirstCategoriesPageState extends State<FirstCategoriesPage> {
  List<Category> categories = [];
  late VeriModeli veriModeli;
  late String veri,
      first_category_id,
      imageBaseUrl =
          "https://www.demo.pigasoft.com/eticaret/panel/uploads/product_second_group_v/350x216/";

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    first_category_id = widget.first_category_id;
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.pink,
        backgroundColor: Colors.white,
        title: Text(
          widget.category.title,
          style: TextStyle(color: Colors.pink[500]),
        ),
      ),
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
            Container(
              height: 1.7,
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 1),
            ),
            SizedBox(height: 5, width: 2),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SecondCategoriesPage(
                            category: category,
                            second_group_id: category.id,
                          )),
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
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/secondCategories/'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
        body: {
          'first_category_id': first_category_id.toString(),
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
                      first_group_id: item['first_group_id'] ?? '',
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
}
