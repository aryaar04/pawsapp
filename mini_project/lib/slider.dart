import 'package:flutter/material.dart';

class ProfileSlider extends StatefulWidget {
  @override
  _ProfileSliderState createState() => _ProfileSliderState();
}

class _ProfileSliderState extends State<ProfileSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.8);

  final List<Map<String, String>> profiles = [
    {"imageUrl": "assets/beagle.jpg", "name": "Buddy"},
    {"imageUrl": "assets/dob2.jpg", "name": "Max"},
    {"imageUrl": "assets/german.jpg", "name": "Bella"},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: _pageController,
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          return ProfileCard(
            imageUrl: profiles[index]["imageUrl"]!,
            name: profiles[index]["name"]!,
          );
        },
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String imageUrl;
  final String name;

  const ProfileCard({
    Key? key,
    required this.imageUrl,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          Container(
            width: 303,
            height: 331,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(43),
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 10,
            child: Opacity(
              opacity: 0.75,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 95),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF95D2B3),
                        fontSize: 25,
                        fontFamily: 'Jua',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      '>',
                      style: TextStyle(
                        color: Color(0xFF95D2B3),
                        fontSize: 25,
                        fontFamily: 'Jua',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
