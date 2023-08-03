import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/Classes/ProductDetailData.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AnasayfaUrunDetayi extends StatefulWidget {
  final String id;
  final String title;

  const AnasayfaUrunDetayi({Key? key, required this.id, required this.title})
      : super(key: key);

  @override
  State<AnasayfaUrunDetayi> createState() => _AnasayfaUrunDetayiState();
}

class _AnasayfaUrunDetayiState extends State<AnasayfaUrunDetayi> {
  ProductDetailData? productData;
  late String productID, productTitle, veri;
  late int isFavoritte = 1;
  late VeriModeli veriModeli;
  final _controller = PageController();
  late var images;

  @override
  void initState() {
    super.initState();
    productID = widget.id;
    productTitle = widget.title;
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
    fetchProductDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildFutureBuilder(),
    );
  }

  FutureBuilder<ProductDetailData?> buildFutureBuilder() {
    return FutureBuilder<ProductDetailData?>(
      future: fetchProductDetail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text('Veri alınamadı!'),
          );
        } else {
          final productData = snapshot.data!;
          return buildListView(productData);
        }
      },
    );
  }

  ListView buildListView(ProductDetailData productData) {
    return ListView(
      children: [
        SizedBox(
          height: 450,
          child: buildPageView(),
        ),
        Center(child: buildSmoothPageIndicator()),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            productData.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Ürün hakkında bilgiler :",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            productData.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
        BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${productData.price} TL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: veriModeli.fav == 1 ? Colors.pink : Colors.grey,
                  ),
                  onPressed: () async {
                    if (veriModeli.fav == 1) {
                      veriModeli.fav = 0;
                    } else {
                      veriModeli.fav = 1;
                    }

                    fetchToggleFavoritte();
                    fetchProductDetail();
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Sepete ekleme işlemi burada gerçekleştirilebilir.
                    setState(() {
                      fetchAddBasket();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.pink, // Arka plan rengi pembe olacak.
                  ),
                  child: Text('Sepete Ekle'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SmoothPageIndicator buildSmoothPageIndicator() {
    return SmoothPageIndicator(
      controller: _controller,
      count: images.length,
      effect: const WormEffect(
        dotHeight: 10,
        dotWidth: 10,
        dotColor: Colors.grey,
        activeDotColor: Colors.pink,
        type: WormType.normal,
      ),
    );
  }

  PageView buildPageView() {
    return PageView.builder(
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      controller: _controller,
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(images[index]),
          ),
        );
      },
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(productTitle),
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
    );
  }

  Future<ProductDetailData?> fetchProductDetail() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/productDetail'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
        body: {
          'product_id': productID,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            veriModeli.setFav(jsonData['isFavoritte']);

            final data = jsonData['data'];
            images = jsonData['images'] ?? [];

            if (data != null && data is Map<String, dynamic>) {
              ProductDetailData.fromJson(data).title;
              return ProductDetailData.fromJson(data);
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
    return null;
  }

  Future<void> fetchToggleFavoritte() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/toggleFavoritte'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
        body: {
          'product_id': productID,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            setState(() {
              fetchProductDetail();
            });
          }
          veriModeli.showNotificationDialog(context, jsonData['message']);
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

  Future<void> fetchAddBasket() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/addBasket'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
          'Cookie': 'ci_session=$veri',
        },
        body: {
          'product_id': productID,
          'qty': "1",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            veriModeli.showNotificationDialog(context, jsonData['message']);
            print(jsonData['message']);
            veriModeli.urunSayisi++;
            setState(() {
              fetchProductDetail();
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
}
