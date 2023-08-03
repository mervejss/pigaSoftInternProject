import 'package:flutter/material.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/NavigationSayfalar/SepetimPage.dart';
import 'package:provider/provider.dart';

class KrediKarti extends StatefulWidget {
  const KrediKarti({Key? key}) : super(key: key);

  @override
  State<KrediKarti> createState() => _KrediKartiState();
}

class _KrediKartiState extends State<KrediKarti> {
  late VeriModeli veriModeli;
  late String veri;

  @override
  void initState() {
    super.initState();
    veriModeli = Provider.of<VeriModeli>(context, listen: false);
    veri = veriModeli.veri;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildSingleChildScrollView(context),
    );
  }

  SingleChildScrollView buildSingleChildScrollView(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Container(
              decoration: buildBoxDecoration(),
              child: Card(
                margin: EdgeInsets.all(10),
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kart Sahibinin Adı"),
                      SizedBox(height: 15),
                      TextField(
                        decoration: buildInputDecoration(),
                      ),
                      SizedBox(height: 25),
                      Text("Kart Numarası"),
                      SizedBox(height: 15),
                      TextField(
                        decoration: buildInputDecoration(),
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Text("Son Kullanım (Ay/Yıl)"),
                          SizedBox(width: 50),
                          Text("Güvenlik Kodu (CVV)"),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            decoration: buildInputDecoration(),
                          )),
                          SizedBox(width: 30),
                          Expanded(
                              child: TextField(
                            decoration: buildInputDecoration(),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: buildBoxDecoration(),
              child: Card(
                margin: EdgeInsets.all(10),
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text("ÖDENECEK TUTAR",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ))),
                      Divider(height: 15, color: Colors.grey, thickness: 1),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text("NET TOPLAM",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Spacer(),
                          Text("${veriModeli.totalTL} TL "),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                          child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SepetimPage()),
                          );
                        },
                        child: Text("${veriModeli.totalTL} TL ÖDE"),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue[800]!),
                        ),
                      ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.0),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Kredi Karti"),
      foregroundColor: Colors.pink,
      backgroundColor: Colors.white,
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}
