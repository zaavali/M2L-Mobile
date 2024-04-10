import 'package:flutter/material.dart';
import 'login.dart'; 
import 'admin.dart';
import 'produitsbdd.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M2L',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => Connection(),
        '/admin': (context) => Admin(isAdmin: false,),
        '/produitsbdd' : (context) => Prodbdd(),
        '/home': (context) => Prodbdd(),
      },
    );
  }
}