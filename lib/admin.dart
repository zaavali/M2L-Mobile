import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'produitsbdd.dart'; // Import de Prodbdd.dart

class Admin extends StatefulWidget {
  final bool isAdmin;

  Admin({required this.isAdmin});

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  bool _loading = true;
  List<Product> _products = []; // Liste des produits

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchProducts(); // Récupérer les produits lorsque la page est chargée
  }

  void _fetchUsers() async {
    // Logique pour récupérer les utilisateurs
  }

  void _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:4000/api/prod/produit'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
          _loading = false; // Mettre _loading à false après avoir récupéré les produits
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length, // Utiliser la taille des produits
              itemBuilder: (context, index) {
                var product = _products[index]; // Récupérer un produit
                return ListTile(
                  title: Text(product.nom), // Utiliser le nom du produit
                  // subtitle: Text(product.description), // Utiliser la description du produit
                  // Ajoutez d'autres éléments du produit ici selon vos besoins
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Prodbdd()),
          );
        },
        tooltip: 'Afficher les produits',
        child: const Icon(Icons.shopping_bag),
      ),
    );
  }
}