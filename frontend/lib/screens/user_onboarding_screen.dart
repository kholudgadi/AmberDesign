import 'package:flutter/material.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // قائمة تحتوي على بيانات الشاشات الثلاث
  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/Fashion.png",
      "title": "اكتشف مصممي الأزياء",
      "subtitle": "تصفح أفضل مصممي الفساتين من سهرة وزواج وحفلات.",
      "button": "التالي",
    },
    {
      "image": "assets/images/Fashion(1).png",
      "title": "اطلب تصميمك",
      "subtitle": "حدد نوع فستانك والمواصفات وسيتولى المصمم الباقي.",
      "button": "التالي",
    },
    {
      "image": "assets/images/Fashion(2).png",
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
    // إجبار الاتجاه من اليمين لليسار لضمان أماكن الأزرار
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black, // خلفية سوداء احتياطية
        body: Stack(
          children: [
            // 1. PageView للصور والنصوص المتغيرة
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
                    // الصورة الخلفية
                    Image.asset(
                      _onboardingData[index]["image"]!,
                      fit: BoxFit.cover,
                    ),
                    
                    // تدرج لوني (Gradient) أسفل الصورة لزيادة وضوح النصوص
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
                    
                    // النصوص (العنوان والتفاصيل)
                    Positioned(
                      bottom: 155, // رفع النصوص لتوفير مساحة للأزرار
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

            // 2. العناصر الثابتة (النقاط والأزرار) فوق الـ PageView
            Positioned(
              bottom: 45,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  // نقاط التصفح (Pagination Dots)
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

                  // صف الأزرار (الزر الرئيسي + زر الرجوع)
                  Row(
                    children: [
                      // الزر الرئيسي (التالي / ابدأ الآن)
                      // أخذ مساحة Expanded ليتمدد بناءً على توفر زر الرجوع
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _onboardingData.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              // مسار الانتقال بعد انتهاء الشاشات الترحيبية
                              debugPrint("انتقال إلى شاشة الدخول أو التسجيل...");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF261732).withOpacity(0.90), // لون الزر الغامق
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
                      
                      // زر الرجوع الدائري (يظهر فقط من الصفحة الثانية وما بعدها)
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
                              color: Colors.white.withOpacity(0.2), // شفافية رمادية
                            ),
                            child: const Icon(
                              Icons.arrow_forward, // سهم يمين لأن الاتجاه RTL
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