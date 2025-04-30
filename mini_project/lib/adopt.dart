import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AdoptPage extends StatefulWidget {
  const AdoptPage({super.key});

  @override
  State<AdoptPage> createState() => _AdoptPageState();
}

class _AdoptPageState extends State<AdoptPage> {
  final String baseUrl = "http://192.168.183.6:8002";
  List dogs = [];

  final nameController = TextEditingController();
  File? selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchDogs();
  }

  Future<void> fetchDogs() async {
    final res = await http.get(Uri.parse("$baseUrl/adopt/list"));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        dogs = data["dogs"];
      });
    }
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> uploadDog(BuildContext dialogContext) async {
    final name = nameController.text.trim();

    if (name.isEmpty || selectedImage == null) return;

    final bytes = await selectedImage!.readAsBytes();
    final base64Image = base64Encode(bytes);

    final res = await http.post(
      Uri.parse("$baseUrl/adopt/upload"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "image": base64Image}),
    );

    if (res.statusCode == 200) {
      Navigator.pop(dialogContext);
      nameController.clear();
      selectedImage = null;
      fetchDogs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dog uploaded successfully")),
      );
    }
  }

  Future<void> adoptDog(String name) async {
    final res = await http.delete(Uri.parse("$baseUrl/adopt/$name"));
    if (res.statusCode == 200) {
      fetchDogs();
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Adopted!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void showUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text("Upload Dog"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Dog Name"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image from Gallery"),
            ),
            if (selectedImage != null) ...[
              const SizedBox(height: 10),
              Image.file(selectedImage!, height: 100),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => uploadDog(dialogContext),
            child: const Text("Upload"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adopt a Dog"),
        backgroundColor: const Color(0xFF6BA8E0),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showUploadDialog,
        backgroundColor: const Color(0xFF6BA8E0),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/adoptbg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Foreground Content
          dogs.isEmpty
              ? const Center(
                  child: Text(
                    "No dogs available for adoption.",
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: dogs.length,
                  itemBuilder: (context, index) {
                    final dog = dogs[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: dog["image"] != null
                                ? Image.memory(
                                    base64Decode(dog["image"]),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.pets, size: 80),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              dog["name"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => adoptDog(dog["name"]),
                            child: const Text(
                              "Adopt",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
