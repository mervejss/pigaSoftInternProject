import 'package:flutter/material.dart';
import 'package:narevim/Providers/VeriModeli.dart';
import 'package:narevim/NavigationSayfalar/AnasayfaPage.dart';
import 'package:narevim/NavigationSayfalar/GirisYapPage.dart';
import 'package:narevim/NavigationSayfalar/KategorilerPage.dart';
import 'package:narevim/NavigationSayfalar/SepetimPage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => VeriModeli(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.pink[500],
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.pink[500],
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VeriModeli veriModeli;
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    AnasayfaPage(),
    KategorilerPage(),
    SepetimPage(),
    GirisYapPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedItemColor: Colors.pink, // Seçili butonun rengi
        unselectedItemColor: Colors.grey, // Seçilmemiş butonların rengi
        selectedLabelStyle: TextStyle(color: Colors.pink), // Seçili etiket rengi
        unselectedLabelStyle: TextStyle(color: Colors.grey), // Seçilmemiş etiket rengi
        showUnselectedLabels: true, // Tüm etiketlerin görünmesini sağlar
        items: _buildBottomNavigationBarItems(),
      ),
    );
  }
  // BottomNavigationBarItem'ları oluşturan method
  List<BottomNavigationBarItem> _buildBottomNavigationBarItems() {
    return [
      // Anasayfa için navigasyon butonu
      bottomNavigationBarItem(Icon(Icons.home),"Anasayfa"),
      // Kategoriler için navigasyon butonu
      bottomNavigationBarItem(Icon(Icons.grid_view_outlined),"Kategoriler"),
      // Sepetim için navigasyon butonu
      bottomNavigationBarItem(Icon(Icons.shopping_cart),"Sepetim"),
      // Hesabım için navigasyon butonu
      bottomNavigationBarItem(Icon(Icons.person_pin),"Hesabım"),
    ];
  }

  // BottomNavigationBarItem'ı oluşturan method
  BottomNavigationBarItem bottomNavigationBarItem(Icon icon, String label) {
    return BottomNavigationBarItem(
      icon: icon,
      label: '$label',
    );
  }
}
