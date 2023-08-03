import 'package:flutter/material.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:provider/provider.dart';

class KapidaOdeme extends StatefulWidget {
  const KapidaOdeme({Key? key}) : super(key: key);

  @override
  State<KapidaOdeme> createState() => _KapidaOdemeState();
}

class _KapidaOdemeState extends State<KapidaOdeme> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kapıda Ödeme"),
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
          return Container(
            padding: EdgeInsetsDirectional.all(15),
            margin: EdgeInsetsDirectional.all(15),
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Icon(Icons.check_circle_outline,
                      size: 150, color: Colors.pink),
                ),
                SizedBox(height: 55),
                Container(
                  padding: EdgeInsetsDirectional.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Sipariş No : ",
                        style: TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                      Text("${snapshot.data}", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Siparişiniz kargoya verildiğinde Sms ile bilgilendirileceksiniz.",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
