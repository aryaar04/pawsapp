import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  Uint8List? _imageBytes;
  String _result = '';
  String _geminiResponse = '';
  bool _loading = false;
  bool _imageSent = false;

  final String apiUrl = 'http://192.168.183.6:8001/predict';
  final String geminiUrl =
      'http://192.168.183.6:8000/gemini_prompt'; // Updated backend

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final imageBytes = await pickedFile.readAsBytes();

    if (imageBytes.lengthInBytes > 2 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Image too large. Please pick one under 2MB.")),
      );
      return;
    }

    setState(() {
      _imageBytes = imageBytes;
      _result = '';
      _geminiResponse = '';
      _imageSent = false;
    });

    await _uploadImage(imageBytes);
  }

  Future<void> _uploadImage(Uint8List imageBytes) async {
    setState(() {
      _loading = true;
    });

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(http.MultipartFile.fromBytes('file', imageBytes,
        filename: 'image.jpg'));

    try {
      var response = await request.send().timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception("Connection timed out"),
          );

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final decoded = jsonDecode(respStr);

        setState(() {
          _result = decoded['result'].toString();
          _imageSent = true;
        });

        await _getGeminiResponse(_result); // Automatically call Gemini
      } else {
        setState(() {
          _result = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Failed: $e';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _getGeminiResponse(String promptText) async {
    try {
      final response = await http.post(
        Uri.parse(geminiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': promptText}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _geminiResponse = decoded['response'].toString();
        });
      } else {
        setState(() {
          _geminiResponse = 'Gemini error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _geminiResponse = 'Failed to fetch Gemini response: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 97, 186, 237); // Sleek Dark Blue
    const backgroundColor = Color(0xFF1D232A); // Dark Gray Background
    const buttonColor = Color(0xFF00B5E2); // Aqua Accent for Buttons

    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Recognition"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor, // Dark background
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_imageBytes != null)
                        Image.memory(_imageBytes!, height: 200),
                      const SizedBox(height: 20),
                      if (_loading) const CircularProgressIndicator(),
                      if (_imageSent)
                        const Text(
                          "Disease detected successfully",
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                      if (_result.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Result: $_result',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (_geminiResponse.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Summary",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0d47a1),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _geminiResponse,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Image"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
