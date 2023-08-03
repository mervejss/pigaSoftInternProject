import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:narevim/AnasayfaSayfalar/AnasayfaUrunDetayi.dart';
import 'package:narevim/AnasayfaSayfalar/AnasayfaUrunleriPage.dart';
import 'package:narevim/AnasayfaSayfalar/BrandsUrunleriPage.dart';
import 'package:narevim/Classes/SliderData.dart';
import 'package:narevim/Classes/Brands.dart';
import 'package:http/http.dart' as http;
import 'package:narevim/Classes/SliderData2.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:provider/provider.dart';

class AnasayfaPage extends StatefulWidget {
  @override
  State<AnasayfaPage> createState() => _AnasayfaPageState();
}

late VeriModeli veriModeli;

class _AnasayfaPageState extends State<AnasayfaPage> {
  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: veriModeli.buildImage(),
        ),
        body: Iskelet(),
      ),
    );
  }
}

class Iskelet extends StatefulWidget {
  @override
  State<Iskelet> createState() => _IskeletState();
}

class _IskeletState extends State<Iskelet> {
  List<SliderData> sliders = [];
  List<Brands> brands = [];
  List<SliderData2> urunler = [];

  String sortingType = 'ASC',
      Url = "https://demo.pigasoft.com/eticaret/apiv1/sliders",
      Url2 = "https://demo.pigasoft.com/eticaret/apiv1/brands",
      imageBaseUrl =
          "http://eticaret.demo.pigasoft.com/panel/uploads/slides_v/1970x500/",
      imageBaseUrl2 =
          "http://eticaret.demo.pigasoft.com/panel/uploads/brands_v/228x290/",
      image_path =
          "https://www.demo.pigasoft.com/eticaret/panel/uploads/product_v/original/"; // ASC or DESC

  TextEditingController searchController = TextEditingController();
  bool isSearchFieldEmpty = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    Future.wait([
      fetchSliders(Url),
      fetchSliders2(Url2),
    ]).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LinearProgressIndicator()
        : Column(
            children: [
              Container(
                padding: EdgeInsetsDirectional.all(7),
                margin: EdgeInsetsDirectional.all(7),
                child: DecoratedBox(
                  decoration: buildBoxDecoration(),
                  child: Container(
                    margin: EdgeInsetsDirectional.only(start: 20, end: 1),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: buildInputDecoration(),
                            onTap: () {
                              buildSetState1();
                            },
                            onSubmitted: (value) {
                              buildSetState2();
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            buildSetState3();
                            veriModeli.showNotificationDialog(context,
                                "Ana sayfaya dönmek için klavyenizden ✓ işaretine veya tekrardan arama alanına tıklamanız yeterli olacaktır !");
                          },
                          icon: Icon(Icons.search),
                          iconSize: 25,
                          color: Colors.pink,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: isSearchFieldEmpty,
                child: buildGestureDetector(),
              ),
              Visibility(
                visible: isSearchFieldEmpty,
                child: Expanded(
                  child: buildGridView(),
                ),
              ),
              Visibility(
                visible: !isSearchFieldEmpty,
                child: Expanded(
                  flex: 7,
                  child: buildListView(),
                ),
              ),
              Visibility(
                visible: !isSearchFieldEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text("MARKALAR", style: buildTextStyle()),
                      buildContainer()
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !isSearchFieldEmpty,
                child: Expanded(
                  flex: 1,
                  child: buildListView2(),
                ),
              ),
            ],
          );
  }

  ListView buildListView2() {
    return ListView.builder(
      shrinkWrap: true, // Yükseklik ihtiyacına göre boyut ayarlamasını sağlar
      scrollDirection: Axis.horizontal,

      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];

        final imageUrl = Uri.encodeComponent('$imageBaseUrl2${brand.img_url}');

        return Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BrandsUrunleriPage(
                          brandID: brand.id, brandTitle: brand.title)),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8.0), // Boşluk eklemek için padding

                child: Image.network(
                  width: 155,
                  height: 50,
                  fit: BoxFit.fill,
                  '$imageBaseUrl2${brand.img_url}',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  TextStyle buildTextStyle() => TextStyle(color: Colors.pink, fontSize: 20);

  Container buildContainer() {
    return Container(
        height: 5,
        width: 150,
        child: Divider(
          height: 1,
          thickness: 2,
          color: Colors.pink,
        ));
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: sliders.length,
      itemBuilder: (context, index) {
        final slider = sliders[index];

        final imageUrl = Uri.encodeComponent('$imageBaseUrl${slider.img_url}');

        return Column(
          children: [
            SizedBox(height: 5, width: 2),
            InkWell(
              onTap: () {
                print(slider.id);

                if (slider.id == 62.toString()) {
                  veriModeli.pageBaslangic = 0;
                  veriModeli.pageBitis = 4;
                } else if (slider.id == 63.toString()) {
                  veriModeli.pageBaslangic = 5;
                  veriModeli.pageBitis = 30;
                } else if (slider.id == 64.toString()) {
                  veriModeli.pageBaslangic = 30;
                  veriModeli.pageBitis = 37;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AnasayfaUrunleriPage(
                          url_string: slider.button_url, sliderID: slider.id)),
                );
                /*
                       veriModeli.pageBaslangic=0-4;//19*2=38
                      veriModeli.pageBaslangic=5-30;//147*2 =294
                      veriModeli.pageBaslangic=30-37;//19*2=38
                       */
              },
              child: ListTile(
                title: Image.network(
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                  '$imageBaseUrl${slider.img_url}',
                ),
              ),
            ),
            Divider(color: Colors.grey),
          ],
        );
      },
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
      itemCount: urunler.length, // Add 1 for the loading indicator.
      itemBuilder: (context, index) {
        final slider2 = urunler[index];
        String img_url = '$image_path${slider2.img_url}';
        return Column(
          children: [
            SizedBox(height: 5, width: 2),
            ProductItemWidget(urun: slider2, img: img_url),
            Divider(color: Colors.grey),
          ],
        );
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

  void buildSetState3() {
    return setState(() {
      fetchSearchProduct(searchController.text);
      searchController.text = "";
    });
  }

  void buildSetState2() {
    return setState(() {
      isSearchFieldEmpty = false;

      if (!isSearchFieldEmpty) {
        searchController.text = "";
        urunler.clear();
        fetchSliders(Url);
        fetchSliders2(Url2);
      }
    });
  }

  void buildSetState1() {
    return setState(() {
      isSearchFieldEmpty = !isSearchFieldEmpty;

      if (!isSearchFieldEmpty) {
        urunler.clear();
        fetchSliders(Url);
        fetchSliders2(Url2);
      }
    });
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
      hintText: 'Aramak istediğiniz ürünü girin...',
      border: InputBorder.none,
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: Colors.pink,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  Future<void> fetchSliders(String url) async {
    try {
      final response = await http.get(
        Uri.parse('$url'),
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
                sliders = List<SliderData>.from(data.map((item) => SliderData(
                      id: item['id'] ?? '',
                      title: item['title'] ?? '',
                      description: item['description'] ?? '',
                      img_url: item['img_url'] ?? '',
                      button_url: item['button_url'] ?? '',
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

  Future<void> fetchSliders2(String url) async {
    try {
      final response = await http.get(
        Uri.parse('$url'),
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
                brands = List<Brands>.from(data.map((item) => Brands(
                      id: item['id'] ?? '',
                      title: item['title'] ?? '',
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

  Future<void> fetchSearchProduct(String keyword) async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/searchProduct'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
        body: {
          'keywords': keyword,
          'page': "0",
          'per_page': "10",
          'sorting': 'ASC',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData != null && jsonData['status'] != null) {
          veriModeli.showNotificationDialog(context, jsonData['message']);

          if (jsonData['status'] == 'success') {
            final data = jsonData['data'];

            print(jsonData['message']);
            if (data != null && data is List) {
              setState(() {
                urunler.addAll(
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
                searchController.text = "";
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

  Future<void> fetchSortingProduct(String sortingType) async {
    try {
      final response = await http.post(
        Uri.parse('https://demo.pigasoft.com/eticaret/apiv1/searchProduct'),
        headers: {
          'X-API-KEY': veriModeli.APIKEY,
        },
        body: {
          'keywords': '',
          'page': "0",
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
                urunler.clear(); // Clear the list before adding new data.

                urunler.addAll(
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
}

class ProductItemWidget extends StatelessWidget {
  const ProductItemWidget({
    Key? key,
    required this.urun,
    required this.img,
  }) : super(key: key);

  final SliderData2 urun;
  final String img;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(5),
      margin: EdgeInsetsDirectional.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildContainer(),
          SizedBox(height: 10),
          Text(
            urun.brand,
            style: buildTextStyle(),
          ),
          Text(
            urun.title,
            style: buildTextStyle2(),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              for (int i = 0; i < 5; i++) buildIcon(i),
              SizedBox(width: 5),
              Text('(${urun.review})', style: TextStyle(fontSize: 10)),
            ],
          ),
          SizedBox(height: 10),
          Center(
            child:
                Text('${urun.price} TL', style: TextStyle(color: Colors.pink)),
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
                            id: urun.id,
                            title: urun.title,
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

  Icon buildIcon(int i) {
    return Icon(
      Icons.star,
      color: i < urun.point ? Colors.yellow : Colors.grey,
      size: 10,
    );
  }

  TextStyle buildTextStyle2() => TextStyle(color: Colors.black, fontSize: 12);

  TextStyle buildTextStyle() {
    return TextStyle(
      color: Colors.blue[800],
      fontWeight: FontWeight.bold,
    );
  }

  Container buildContainer() {
    return Container(
      width: 100,
      height: 100,
      child: Image.network(
        '$img',
        fit: BoxFit.fitHeight,
      ),
    );
  }
}
