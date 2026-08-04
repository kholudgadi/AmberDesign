import 'package:flutter/material.dart';
import 'login_screen.dart'; 

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data for the onboarding screens, including images, titles, subtitles, and button labels.
  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/evening.png",
      "title": "اكتشف مصممي الأزياء",
      "subtitle": "تصفح أفضل مصممي الفساتين من سهرة وزواج وحفلات.",
      "button": "التالي",
    },
    {
      "image": "assets/images/wedding.png",
      "title": "اطلب تصميمك",
      "subtitle": "حدد نوع فستانك والمواصفات وسيتولى المصمم الباقي.",
      "button": "التالي",
    },
    {
      "image": "assets/images/party.png",
      "title": "استلمي وقيّمي",
      "subtitle": "استلمي فستانك المميز وشاركي تجربتك مع المجتمع.",
      "button": "ابدأ الآن",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The main structure of the onboarding screen, including a PageView for swiping through onboarding pages and navigation buttons.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black, 
        body: Stack(
          children: [
            // page view for onboarding screens
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // image for the onboarding screen
                    Image.asset(
                      _onboardingData[index]["image"]!,
                      fit: BoxFit.cover,
                    ),
                    
                    // Overlay to darken the image for better text visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                    
                    // Positioned text for title and subtitle
                    Positioned(
                      bottom: 155, 
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _onboardingData[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _onboardingData[index]["subtitle"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // Positioned widget for pagination dots and navigation buttons at the bottom of the screen.
            Positioned(
              bottom: 45,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  // Pagination dots indicating the current onboarding page.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: _currentPage == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Row containing the main navigation button and a back button (if applicable) for the onboarding screens.
                  Row(
                    children: [
                      // Main navigation button to proceed to the next onboarding screen or finish the onboarding process.
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _onboardingData.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(isDesigner: false),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF261732).withOpacity(0.90), 
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _onboardingData[_currentPage]["button"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      //
                      if (_currentPage > 0) ...[
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 56,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: const Icon(
                              Icons.arrow_forward, 
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}