import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'produitsbdd.dart'; 

class Admin extends StatefulWidget {
  final bool isAdmin;

  Admin({required this.isAdmin});

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  bool _loading = true;
  List<Product> _products = []; 

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchProducts(); 
  }

  void _fetchUsers() async {
    
  }

  void _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:4000/api/prod/produit'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
          _loading = false; 
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
              itemCount: _products.length,
              itemBuilder: (context, index) {
                var product = _products[index]; 
                return ListTile(
                  title: Text(product.nom), 
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