import 'dart:ui'; // Required for the blur effect used in the domain cards.
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import 'designer_profile_setup_screen.dart';

class DesignerDomainScreen extends StatefulWidget {
  const DesignerDomainScreen({super.key});

  @override
  State<DesignerDomainScreen> createState() => _DesignerDomainScreenState();
}

class _DesignerDomainScreenState extends State<DesignerDomainScreen> {
  // Stores the user's selected domain.
  String? _selectedDomain;

  final List<Map<String, String>> domains = [
    {
      'id': 'fashion',
      'title': 'تصميم الأزياء',
      'sub': 'فساتين، عبايات، ملابس رسمية',
      'image':
          'https://images.unsplash.com/photo-1617258856138-402b60da4e2a?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mjl8fGRyZXNzZXN8ZW58MHx8MHx8fDA%3D',
    },
    {
      'id': 'interior',
      'title': 'التصميم الداخلي',
      'sub': 'ديكور، مساحات داخلية، ألوان',
      'image':
          'https://images.unsplash.com/photo-1664711942326-2c3351e215e6?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGludGVyaW9yJTIwZGVzaWdufGVufDB8fDB8fHww',
    },
    {
      'id': 'exterior',
      'title': 'التصميم الخارجي',
      'sub': 'واجهات، مناظر طبيعية، هندسة',
      'image':
          'https://images.unsplash.com/photo-1678575326996-a1bf09b86158?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nzl8fGV4dGVyaW9yfGVufDB8fDB8fHww',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'ما مجالك؟',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر التخصص الذي تعمل فيه',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textMuted.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // List of available design domains.
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: domains.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final domain = domains[index];
                        final isSelected = _selectedDomain == domain['id'];

                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDomain = domain['id']),
                          child: _buildDomainCard(domain, isSelected),
                        );
                      },
                    ),
                  ),

                  // Next button to continue to the profile setup step.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedDomain == null
                          ? null
                          : () {
                              String domainName = domains.firstWhere(
                                (d) => d['id'] == _selectedDomain,
                              )['title']!;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DesignerProfileSetupScreen(
                                        domainName: domainName,
                                      ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textDark.withOpacity(0.80),
                        disabledBackgroundColor: AppColors.textMuted
                            .withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'التالي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _selectedDomain == null
                              ? Colors.white70
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDomainCard(Map<String, String> domain, bool isSelected) {
    // Builds the main card container with shadow and glass effects.
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), 
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // Clips the card so the blur effect applies only inside the rounded container.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12.0,
            sigmaY: 12.0,
          ), // Applies the blur effect.
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              // Changes the card color to indicate whether the domain is selected.
              color: isSelected
                  ? AppColors.textDark
                  : Colors.white.withOpacity(0.4),
            ),
            child: Row(
              children: [
                // Radio-style icon showing whether the domain is selected.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                ),

                // Domain title and subtitle.
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        domain['title']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        domain['sub']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white70
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Domain cover image.
                SizedBox(
                  width: 100,
                  height: double.infinity,
                  child: Image.network(domain['image']!, fit: BoxFit.cover),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
