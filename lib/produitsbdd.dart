import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'login.dart'; // Ajout de l'import manquant
import 'dart:io';

class Product {
  final String puid;
  final String nom;
  final String description;
  final double prix;
  final int quantite;
  final String img;

  Product({
    required this.puid,
    required this.nom,
    required this.description,
    required this.prix,
    required this.quantite,
    required this.img,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      puid: json['puid'],
      nom: json['nom'],
      description: json['description'],
      prix: json['prix']?.toDouble() ?? 0.0,
      quantite: json['quantite'],
      img: json['img'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'puid': puid,
      'nom': nom,
      'description': description,
      'prix': prix,
      'quantite': quantite,
      'img': img,
    };
  }
}

class Prodbdd extends StatefulWidget {
  @override
  _ProdbddState createState() => _ProdbddState();
}

class _ProdbddState extends State<Prodbdd> {
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://localhost:4000/api/prod/produit'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost:4000/api/prod/produit/${updatedProduct.puid}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updatedProduct.toJson()),
      );

      if (response.statusCode == 200) {
        setState(() {
          _products = fetchProducts();
        });
        print('Product updated successfully: ${updatedProduct.nom}');
      } else {
        throw Exception('Failed to update product');
      }
    } catch (error) {
      print('Error updating product: $error');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:4000/api/prod/produit/$productId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _products = fetchProducts();
        });
        print('Product deleted successfully: ID $productId');
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (error) {
      print('Error deleting product: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des produits'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(243, 129, 72, 0.953),
      ),
      body: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditProductPage(
                          product: snapshot.data![index],
                          onUpdate: updateProduct);
                    }));
                  },
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.network(
                            'http://localhost:4000/${snapshot.data![index].img}',
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: 150,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                snapshot.data![index].nom,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${snapshot.data![index].prix.toStringAsFixed(2)} €',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                     Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Expanded(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditProductPage(
                product: snapshot.data![index],
                onUpdate: updateProduct,
              ),
            ),
          );
        },
        child: Text('Modifier'),
      ),
    ),
    Expanded(
      child: ElevatedButton(
        onPressed: () {
          deleteProduct(snapshot.data![index].puid);
        },
        child: Text('Supprimer'),
      ),
    ),
  ],
),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddProductPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar:
          CustomNavBar(selectedIndex: 0, onItemTapped: (int) {}),
    );
  }
}

class EditProductPage extends StatefulWidget {
  final Product product;
  final Function(Product) onUpdate;

  EditProductPage({required this.product, required this.onUpdate});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _prixController;
  late TextEditingController _quantiteController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.product.nom);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _prixController =
        TextEditingController(text: widget.product.prix.toString());
    _quantiteController =
        TextEditingController(text: widget.product.quantite.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le produit'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _prixController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Prix'),
              ),
              TextFormField(
                controller: _quantiteController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantité'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  final updatedProduct = Product(
                    puid: widget.product.puid,
                    nom: _nomController.text,
                    description: _descriptionController.text,
                    prix: double.parse(_prixController.text),
                    quantite: int.parse(_quantiteController.text),
                    img: widget.product.img,
                  );
                  widget.onUpdate(updatedProduct);
                  Navigator.of(context).pop();
                },
                child: Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _prixController;
  late TextEditingController _quantiteController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _descriptionController = TextEditingController();
    _prixController = TextEditingController();
    _quantiteController = TextEditingController();
    _imagePath = null;
  }

  Future<String?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      print('No image selected.');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un produit'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: _prixController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Prix'),
            ),
            TextFormField(
              controller: _quantiteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantité'),
            ),
            ElevatedButton(
              onPressed: () async {
                _imagePath = await pickImage();
                setState(() {});
              },
              child: Text('Choisir une image'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _addProduct();
              },
              child: Text('Ajouter le produit'),
            ),
            if (_imagePath != null) ...[
              SizedBox(height: 16.0),
              Text('Image sélectionnée : $_imagePath'),
            ],
          ],
        ),
      ),
    );
  }

Future<void> _addProduct() async {
  final double? prix = double.tryParse(_prixController.text);
  final int? quantite = int.tryParse(_quantiteController.text);

  if (prix == null || quantite == null) {
    print('Prix ou quantité invalide');
    return;
  }

  try {
    FormData formData = FormData.fromMap({
      'nom': _nomController.text,
      'description': _descriptionController.text,
      'prix': prix.toString(),
      'quantite': quantite.toString(),
    });

    if (_imagePath != null) {
      // Handle file upload for non-web platforms
      if (!kIsWeb) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(_imagePath!),
        ));
      } else {
        // Handle file upload for web platform
        // You may need to adjust this part depending on your backend setup
        // For example, you might need to upload the image to a cloud storage service and provide the URL in the formData
        formData.fields.add(MapEntry(
          'image',
          _imagePath!,
        ));
      }
    }

    
      Response response = await Dio().post(
        'http://localhost:4000/api/prod/produit',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );


    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      throw Exception('Failed to add product');
    }
  } catch (error) {
    print('Error adding product: $error');
  }
}
  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }
}

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Business',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'School',
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
  
  ));
}
