import 'package:flutter/material.dart';

class VeriModeli extends ChangeNotifier {
  String APIKEY = 'SSVa97j7z83nMXDzhmmdHSSLPG9NueDf3J6BgCSS';
  String veri = '', ePosta = '', sifre = '';
  late var ci_session,
      fav,
      urunSayisi = 0,
      image_path,
      totalQTY,
      totalTL,
      order_number,
      addressID,
      pageBaslangic = 0,
      pageBitis = 37,
      currentPageIndex = 0;

  void setVeri(var yeniVeri) {
    veri = yeniVeri;
    notifyListeners();
  }

  void setEposta(String yeniEposta) {
    ePosta = yeniEposta;
    notifyListeners();
  }

  void setSifre(String yeniSifre) {
    sifre = yeniSifre;
    notifyListeners();
  }

  void setCi_session(String yenisession) {
    ci_session = yenisession;
    notifyListeners();
  }

  void setFav(int yeniFav) {
    fav = yeniFav;
    notifyListeners();
  }

  Image buildImage() {
    return Image.asset(
      'assets/narlogo.jpg',
      width: 150,
      height: 70,
      color: Colors.pink[500],
    );
  }

  void showNotificationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Narevim"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
