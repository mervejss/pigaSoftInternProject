import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/AnasayfaSayfalar/AnasayfaUrunDetayi.dart';
import 'package:narevim/Classes/SliderData2.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:provider/provider.dart';

class AnasayfaUrunleriPage extends StatefulWidget {
  var url_string, sliderID;
  AnasayfaUrunleriPage(
      {Key? key, required this.url_string, required this.sliderID});

  @override
  State<AnasayfaUrunleriPage> createState() => _AnasayfaUrunleriPageState();
}

final String imageBaseUrl =
    "https://www.demo.pigasoft.com/eticaret/panel/uploads/product_v/original/";

class _AnasayfaUrunleriPageState extends State<AnasayfaUrunleriPage> {

  List<SliderData2> sliders2 = [];
  final String img_url = '', sortingType = 'ASC';
  ScrollController _scrollController = ScrollController();

  late VeriModeli veriModeli;
  var sliderID;
  late int pageValue, pageValueBitis;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    pageValue = veriModeli.pageBaslangic;
    pageValueBitis = veriModeli.pageBitis;
    _scrollController.addListener(_onScroll);
    sliderID = widget.sliderID;
    fetchGetUrl(widget.url_string.toString());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Container(
        child: Column(
          children: [
            buildGestureDetector(),
            SizedBox(height: 1, child: Container(color: Colors.pink)),
            Expanded(
              child: buildGridView(),
            ),
          ],
        ),
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
      controller: _scrollController,
      itemCount: sliders2.length + 1,
      itemBuilder: (context, index) {
        if (index < sliders2.length) {
          final slider2 = sliders2[index];
          String img_url = '$imageBaseUrl${slider2.img_url}';
          return Column(
            children: [
              SizedBox(height: 5, width: 2),
              ProductItemWidget(slider2: slider2, img: img_url),
              Divider(color: Colors.grey),
            ],
          );
        } else if (pageValue < pageValueBitis) {
          return Center(child: CircularProgressIndicator());
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  GestureDetector buildGestureDetector() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showSortingDialog(); // Dialogı göstermek için çağırıyoruz
        });
      },
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
      title: Text("Kampanyalı Ürünler"),
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
    );
  }

  Future<void> fetchGetUrl(String url_string) async {
    try {
      if (pageValue < pageValueBitis) {
        setState(() {
          pageValue++;
          print(pageValue);
        });
      }

      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/getUrl'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
        body: {
          'url_string': url_string,
          'per_page': '10',
          'page': pageValue.toString(),
          'sorting': 'ASC',
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
                sliders2.addAll(
                    List<SliderData2>.from(data.map((item) => SliderData2(
                          id: item['id'] ?? '',
                          title: item['title'] ?? '',
                          price: item['price'] ?? '',
                          discount_price: item['discount_price'] ?? '',
                          img_url: item['img_url'] ?? '',
                          brand: item['brand'] ?? '',
                          point: item['point'] ?? 0,
                          review: item['review'] ?? '',
                          discountRatio: item['discountRatio'] ?? 0,
                        ))));
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

  Future<void> fetchSortingProduct(String sortingType) async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/searchProduct'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
        body: {
          'keywords': '',
          'page': pageValue.toString(),
          'per_page': '10',
          'sorting': '$sortingType',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData['status'] != null) {
          if (jsonData['status'] == 'success') {
            final data = jsonData['data'];
            print(jsonData['message']);
            if (data != null && data is List) {
              veriModeli.showNotificationDialog(context, jsonData['message']);

              setState(() {
                sliders2.clear(); // Clear the list before adding new data.

                sliders2.addAll(
                    List<SliderData2>.from(data.map((item) => SliderData2(
                          id: item['id'] ?? '',
                          title: item['title'] ?? '',
                          price: item['price'] ?? '',
                          discount_price: item['discount_price'] ?? '',
                          img_url: item['img_url'] ?? '',
                          brand: item['brand'] ?? '',
                          point: item['point'] ?? 0,
                          review: item['review'] ?? '',
                          discountRatio: item['discountRatio'] ?? 0,
                        ))));
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
                          fetchSortingProduct('ASC');
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
                          fetchSortingProduct('DESC');
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

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Reached the bottom of the list, load more data.
      if (pageValue < pageValueBitis) {
        fetchGetUrl(widget.url_string.toString());
      }
    }
  }
}

class ProductItemWidget extends StatelessWidget {
  const ProductItemWidget({
    Key? key,
    required this.slider2,
    required this.img,
  }) : super(key: key);

  final SliderData2 slider2;
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
            slider2.brand,
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            slider2.title,
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              for (int i = 0; i < 5; i++)
                Icon(
                  Icons.star,
                  color: i < slider2.point ? Colors.yellow : Colors.grey,
                  size: 10,
                ),
              SizedBox(width: 5),
              Text('(${slider2.review})', style: TextStyle(fontSize: 10)),
            ],
          ),
          SizedBox(height: 10),
          Center(
            child: Text('${slider2.price} TL',
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
                          id: slider2.id, title: slider2.title)),
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
