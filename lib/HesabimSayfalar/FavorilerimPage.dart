import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/AnasayfaSayfalar/AnasayfaUrunDetayi.dart';
import 'package:narevim/Classes/Favoritte.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:provider/provider.dart';

class FavorilerimPage extends StatefulWidget {
  @override
  State<FavorilerimPage> createState() => _FavorilerimPageState();
}

class _FavorilerimPageState extends State<FavorilerimPage> {
  List<Favoritte> favoritteList = [];
  late VeriModeli veriModeli;
  late String veri;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
    fetchFavoritteList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: buildGridView(),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Favori Ürünlerim"),
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
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
      itemCount: favoritteList.length,
      itemBuilder: (context, index) {
        Favoritte favoriUrun = favoritteList[index];

        return Container(
          padding: EdgeInsetsDirectional.all(5),
          margin: EdgeInsetsDirectional.all(2),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                'https://www.demo.pigasoft.com/eticaret/panel/uploads/product_v/original/${favoriUrun.imgUrl}',
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  favoriUrun.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildIcon(),
                  buildIcon(),
                  buildIcon(),
                  buildIcon(),
                  buildIcon(),
                  SizedBox(width: 5),
                  Text(
                    '(${favoriUrun.review})',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '${favoriUrun.price} TL',
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnasayfaUrunDetayi(
                          id: favoriUrun.id, title: favoriUrun.title),
                    ),
                  ).then((_) {
                    fetchFavoritteList();
                  });
                },
                style: buildButtonStyle(),
                child: Text(
                  "Ürün Detayı",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchFavoritteList() async {
    try {
      final response = await http.get(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/favoritte'),
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
              setState(() {
                favoritteList =
                    List<Favoritte>.from(data.map((item) => Favoritte(
                          value: item['value'] ?? '',
                          id: item['id'] ?? '',
                          url: item['url'] ?? '',
                          codeUrl: item['code_url'] ?? '',
                          isHome: item['isHome'] ?? '',
                          isActive: item['isActive'] ?? '',
                          price: item['price'] ?? '',
                          discountPrice: item['discount_price'] ?? '',
                          title: item['title'] ?? '',
                          desi: item['desi'] ?? '',
                          isDiscount: item['isDiscount'] ?? '',
                          imgUrl: item['img_url'] ?? '',
                          isCover: item['isCover'] ?? '',
                          productId: item['product_id'] ?? '',
                          memberId: item['member_id'] ?? '',
                          brandTitle: item['brand_title'] ?? '',
                          point: int.parse(item['point'].toString() ?? '0'),
                          review: int.parse(item['review'].toString() ?? '0'),
                          discountRatio: double.parse(
                              item['discountRatio'].toString() ?? '0'),
                        )));
              });
            }
            print(jsonData['message']);
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

  Icon buildIcon() {
    return Icon(
      Icons.star,
      color: Colors.yellow[800],
    );
  }

  ButtonStyle buildButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        // Return the color based on different states if needed.
        return Colors.white;
      }),
      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        // Return the color based on different states if needed.
        return Colors.black;
      }),
      side: MaterialStateProperty.all<BorderSide>(
          BorderSide(color: Colors.grey, width: 1.0)),
    );
  }
}
