import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'produitsbdd.dart'; 

class Connection extends StatefulWidget {
  @override
  _ConnectionState createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _loginMessage = '';
  
  get cookieJar => null;

  void _handleLog() async {
    try {
      var client = http.Client();
     var response = await client.post(
  Uri.parse('http://localhost:4000/api/user/conn'),
        body: jsonEncode({
          'email': _emailController.text,
          'mdp': _passwordController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var token = data['token'];
        var isAdmin = data['isAdmin'];
     

        SharedPreferences prefs = await SharedPreferences.getInstance();
      

        if (isAdmin) {
          Navigator.pushNamed(context, '/produitsbdd');
        } else {
          setState(() {
            _loginMessage = 'Vous n\'êtes pas autorisé à accéder à cette page.';
          });
        }
      } else {
        setState(() {
          _loginMessage =
              'Échec de la connexion. Veuillez vérifier vos informations.';
        });
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Maison des Ligues de Lorraine'),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        backgroundColor: Color.fromRGBO(243, 129, 72, 0.953),
        titleTextStyle: const TextStyle(fontSize: 23.0, color: Color.fromARGB(255, 255, 255, 255)), 
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
              child: Image.asset('../assets/logo.png', fit: BoxFit.cover),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 50,
                right: 50,
                top: 25,
                bottom: 0,
              ), 
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Adresse mail',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 50,
                right: 50,
                top: 15,
                bottom: 0,
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Mot de passe',
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 40,
              width: 200,
              decoration: BoxDecoration(
                color: Color.fromRGBO(243, 129, 72, 0.953),
                borderRadius: BorderRadius.circular(20),
              ),
              child: MaterialButton(
                onPressed: _handleLog,
                child: Text(
                  'Se connecter',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(_loginMessage),
            SizedBox(
              height: 130,
            ),
          ],
        ),
      ),
    );
  }
}