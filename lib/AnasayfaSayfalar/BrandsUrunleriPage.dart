import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/AnasayfaSayfalar/AnasayfaUrunDetayi.dart';
import 'package:narevim/Classes/Brand.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:provider/provider.dart';

class BrandsUrunleriPage extends StatefulWidget {
  var brandID, brandTitle;

  BrandsUrunleriPage(
      {Key? key, required this.brandID, required this.brandTitle})
      : super(key: key);

  @override
  State<BrandsUrunleriPage> createState() => _BrandsUrunleriPageState();
}

class _BrandsUrunleriPageState extends State<BrandsUrunleriPage> {
  var brandID, brandTitle;
  late VeriModeli veriModeli;
  List<Brand> brands = [];
  String image_path =
      'https://www.demo.pigasoft.com/eticaret/panel/uploads/product_v/original/';
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);

    brandID = widget.brandID;
    brandTitle = widget.brandTitle;
    fetchBrandProductList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          buildGestureDetector(),
          SizedBox(height: 1, child: Container(color: Colors.pink)),
          Expanded(
            child: buildGridView(),
          ),
        ],
      ),
    );
  }

  GridView buildGridView() {
    return GridView.builder(
      primary: false,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 1 / 2,
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
        return Column(
          children: [
            SizedBox(height: 5, width: 2),
            ProductItemWidget(
                brandData: brand, img: '$image_path${brand.imgUrl}'),
            Divider(color: Colors.grey),
          ],
        );
      },
    );
  }

  GestureDetector buildGestureDetector() {
    return GestureDetector(
      onTap: _showSortingDialog,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sort,
            size: 50,
            color: Colors.pink,
          ),
          Text(
            "Sırala",
            style: TextStyle(color: Colors.pink),
          ),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("$brandTitle"),
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
    );
  }

  Future<void> fetchBrandProductList() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/brandProductList'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
        body: {
          'page': '0',
          'per_page': '10',
          'brand_id': brandID,
          'sorting': isAscending ? 'ASC' : 'DESC',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            final data = jsonData['data'];
            print(jsonData['message']);
            if (data != null && data is List) {
              setState(() {
                brands =
                    List<Brand>.from(data.map((item) => Brand.fromJson(item)));
              });
              veriModeli.showNotificationDialog(context, jsonData['message']);
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

  void toggleSortOrder() {
    setState(() {
      isAscending = !isAscending;
      fetchBrandProductList();
    });
  }

  void _showSortingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ürünleri Sırala',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isAscending = true;
                          fetchBrandProductList();
                        });
                        Navigator.pop(context); // Dialog kapatılacak
                      },
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.pink),
                          SizedBox(width: 5),
                          Text('Fiyata Göre Artan'),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isAscending = false;
                          fetchBrandProductList();
                        });
                        Navigator.pop(context); // Dialog kapatılacak
                      },
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.pink),
                          SizedBox(width: 5),
                          Text('Fiyata Göre Azalan'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Dialog kapatılacak
                  },
                  child: Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductItemWidget extends StatelessWidget {
  const ProductItemWidget({
    Key? key,
    required this.brandData,
    required this.img,
  }) : super(key: key);

  final Brand brandData;
  final String img;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(5),
      margin: EdgeInsetsDirectional.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 100,
            height: 100,
            child: Image.network(
              '$img',
              fit: BoxFit.fitHeight,
            ),
          ),
          SizedBox(height: 10),
          Text(
            brandData.brand,
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            brandData.title,
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              for (int i = 0; i < 5; i++)
                Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: 10,
                ),
              SizedBox(width: 5),
              Text('()', style: TextStyle(fontSize: 10)),
            ],
          ),
          SizedBox(height: 10),
          Center(
            child: Text('${brandData.price} TL',
                style: TextStyle(color: Colors.pink)),
          ),
          SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              style: buildButtonStyle(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AnasayfaUrunDetayi(
                            id: brandData.id,
                            title: brandData.title,
                          )),
                );
              },
              child: Text('Ürün Detayı'),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  ButtonStyle buildButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1.0),
          side: BorderSide(color: Colors.grey, width: 1.0),
        ),
      ),
    );
  }
}
