import 'package:flutter/material.dart';
import 'package:mini_project/api.dart';
import 'package:mini_project/image.dart';
import 'package:mini_project/shop.dart';
import 'package:mini_project/adopt.dart';
import 'package:mini_project/login_signup.dart'; // Make sure this is the correct path

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                "assets/bg.jpg",
                fit: BoxFit.cover,
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with profile avatar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 10),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Log out?"),
                                content: const Text(
                                    "Are you sure you want to log out?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginSignupPage()),
                                        (route) => false,
                                      );
                                    },
                                    child: const Text("Logout"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          backgroundImage: AssetImage("assets/obama.jpg"),
                          radius: 25,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Welcome to",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    "Paws App 🐾",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Your ultimate pet companion!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Grid Cards
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      children: [
                        buildModeCard(
                          label: "AI bot",
                          color: const Color(0xCCFFD280),
                          icon: Icons.smart_toy,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatBotPage()),
                          ),
                        ),
                        buildModeCard(
                          label: "Skin disease Recognition",
                          color: const Color(0xCCB3E5FC),
                          icon: Icons.image_search,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ImagePage()),
                          ),
                        ),
                        buildModeCard(
                          label: "Shop",
                          color: const Color(0xCCE1BEE7),
                          iconPath: "assets/shop.png",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ShopPage()),
                          ),
                        ),
                        buildModeCard(
                          label: "Adopt",
                          color: const Color(0xCCC8E6C9),
                          iconPath: "assets/love.png",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AdoptPage()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Navigation Bar
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: screenWidth * 0.95,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xCCEAF2F8),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset("assets/home.png", width: 30, height: 30),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ShopPage()),
                            );
                          },
                          child: Image.asset("assets/store.png",
                              width: 30, height: 30),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildModeCard({
    required String label,
    required Color color,
    String? iconPath,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            iconPath != null
                ? Image.asset(iconPath,
                    width: 30, height: 30, color: Colors.black87)
                : Icon(icon, size: 30, color: Colors.black87),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
