import 'package:flutter/material.dart';
import 'package:ia/HomePage.dart';
import 'package:ia/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create and initialize SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  MyApp(this.prefs);

  @override
  Widget build(BuildContext context) {
    // prefs.clear();
    var screen =
        prefs.getString('token') != null ? HomePage(prefs) : LoginPage(prefs);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Web Login',
      home: screen,
    );
  }
}
