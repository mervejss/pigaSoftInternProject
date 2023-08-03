import 'package:flutter/material.dart';

class EmailProvider extends ChangeNotifier {
  TextEditingController ePostaTec = TextEditingController();

  void setEposta(String email) {
    ePostaTec.text = email;
    notifyListeners();
  }
}