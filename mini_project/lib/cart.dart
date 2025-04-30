import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List cartItems = [];
  final String baseUrl = "http://192.168.183.6:8002";

  Future<void> fetchCart() async {
    final response = await http.get(Uri.parse("$baseUrl/cart"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cartItems = data['cart'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load cart")),
      );
    }
  }

  Future<void> removeFromCart(String name) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/remove-from-cart/$name"));
    if (response.statusCode == 200) {
      fetchCart();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to remove item")),
      );
    }
  }

  void showConfirmationPopup() {
    int total = cartItems.fold(
      0,
      (sum, item) => sum + int.parse(item['price'].replaceAll('₹', '')),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Order Confirmed"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Your order has been placed."),
            const SizedBox(height: 10),
            Text("Total: ₹$total"),
            const SizedBox(height: 5),
            const Text("Payment: Cash on Delivery"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to shop
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    const Color blueTheme = Color(0xFF6BA8E0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: blueTheme,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/${item['image']}',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['price'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black, // price in black
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => removeFromCart(item['name']),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: showConfirmationPopup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueTheme,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Purchase",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
    );
  }
}
