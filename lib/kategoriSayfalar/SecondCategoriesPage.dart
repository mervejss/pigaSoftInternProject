import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:narevim/Classes/Category.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/kategoriSayfalar/ThirdCategoriesPage.dart';
import 'package:provider/provider.dart';

class SecondCategoriesPage extends StatefulWidget {
  final Category category;

  var second_group_id;

  SecondCategoriesPage({required this.category, required this.second_group_id});

  @override
  State<SecondCategoriesPage> createState() => _SecondCategoriesPageState();
}

class _SecondCategoriesPageState extends State<SecondCategoriesPage> {
  List<Category> categories = [];
  late VeriModeli veriModeli;
  late String veri,
      second_group_id,
      imageBaseUrl =
          "https://www.demo.pigasoft.com/eticaret/panel/uploads/product_third_group_v/350x216/";

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    second_group_id = widget.second_group_id;
    fetchCategories(); // İkinci kategorileri al
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
                      builder: (context) => ThirdCategoriesPage(
                            category: category,
                            third_group_id: category.id,
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

  AppBar buildAppBar() {
    return AppBar(
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
      title: Text(
        widget.category.title,
        style: TextStyle(color: Colors.pink[500]),
      ),
    );
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/thirdCategories'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
        body: {
          'second_category_id': second_group_id.toString(),
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
                      second_group_id: item['second_group_id'] ?? '',
                      url: item['url'] ?? '',
                      title: item['title'] ?? '',
                      description: item['description'] ?? '',
                      img_url: item['img_url'] ?? '',
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
