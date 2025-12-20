import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/views/components/primary_button.dart';
import 'package:frontend/views/onboarding/start_screen.dart';
import 'package:hive/hive.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final List<Map<String, String>> _pages = [
    {
      "image": "assets/onboad/Onboard1.svg",
      "title": "Manage your tasks",
      "desc": "You can easily manage all of your daily tasks in DoMe for free",
    },
    {
      "image": "assets/onboad/Onboard2.svg",
      "title": "Create daily routine",
      "desc": "In UpTodo you can create your personalized routine to stay productive",
    },
    {
      "image": "assets/onboad/Onboard3.svg",
      "title": "Organize your tasks",
      "desc": "You can organize your daily tasks by adding your tasks into separate categories",
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _skip();
    }
  }

  void _skip() async {
    
    var box = Hive.box('settings');
    await box.put('isFirstTime', false);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StartScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    "SKIP",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                     return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(page["image"]!, height: 260),
                          const SizedBox(height: 40),
                          Text(
                            page["title"]!,
                            style: Theme.of(context).textTheme.headlineLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 42),
                          Text(
                            page["desc"]!,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                )
              ),
          
               Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(4),
                      width: _currentPage == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
          
                const SizedBox(height: 24),
          
                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () => _controller.previousPage(
                              duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
                          child: Text(
                            "BACK",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 60), // giữ khoảng trống cho căn giữa
                        PrimaryButton(
                          onPressed: _nextPage,
                          text: _currentPage == _pages.length - 1 ? "GET STARTED" : "NEXT",
                        )
                    ],
                  ),
                ),
            ],
          ),
        ),
      )
    );
  }
}