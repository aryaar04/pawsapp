import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final List<Map<String, String>> products = [
    {
      'name': 'Dog Food',
      'price': '350',
      'image': 'food.jpg',
      'asset': 'assets/food.jpg',
    },
    {
      'name': 'Toy',
      'price': '120',
      'image': 'toy.jpg',
      'asset': 'assets/toy.jpg',
    },
    {
      'name': 'Pet Shampoo',
      'price': '200',
      'image': 'shampoo.jpg',
      'asset': 'assets/shampoo.jpg',
    },
    {
      'name': 'Pet Bed',
      'price': '899',
      'image': 'bed.jpg',
      'asset': 'assets/bed.jpg',
    },
    {
      'name': 'Sunglass',
      'price': '829',
      'image': 'glass.jpg',
      'asset': 'assets/glass.jpg',
    },
  ];

  final String baseUrl = "http://192.168.183.6:8002";

  Future<void> addToCart(Map<String, String> product) async {
    final cartItem = {
      "name": product['name']!,
      "price": product['price']!,
      "image": product['image']!,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/add-to-cart'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(cartItem),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${product['name']} added to cart")),
      );
    } else {
      final body = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(body['detail'] ?? "Failed to add to cart")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    const Color blueTheme = Color(0xFF6BA8E0); // New blue color

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Pet Shop'),
        backgroundColor: blueTheme,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: blueTheme,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          );
        },
        child: const Icon(Icons.shopping_cart),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: width < 400 ? 0.75 : 0.8,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Image.asset(
                      product['asset']!,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${product['price']!}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black, // price in black
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => addToCart(product),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blueTheme,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                            ),
                            child: const Text("Add"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
