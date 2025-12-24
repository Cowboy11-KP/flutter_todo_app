import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/views/auth/login_screen.dart';
import 'package:frontend/views/home/home_screen.dart';
import 'package:frontend/views/onboarding/onboarding_screen.dart';
import 'package:hive/hive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Đợi 2 giây để hiển thị Logo/Animation
    await Future.delayed(const Duration(seconds: 2));

    var box = Hive.box('settings');
    
    // 1. Kiểm tra Onboarding (mở lần đầu hay lần 2)
    bool isFirstTime = box.get('isFirstTime', defaultValue: true);

    if (isFirstTime) {
      // Nếu lần đầu, chuyển tới Onboarding và đánh dấu đã xem
      await box.put('isFirstTime', false);
      _navigateTo(const OnboardingScreen());
      return;
    }

    // 2. Kiểm tra Duy trì đăng nhập (Remember Me)
    bool isRememberMe = box.get('isRememberMe', defaultValue: false);
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (isRememberMe && currentUser != null) {
      // Nếu có tích Remember me và đã từng login thành công
      _navigateTo(const HomeScreen());
    } else {
      // Ngược lại bắt đăng nhập lại
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/logo.svg', width: 113, height: 113,),
            const SizedBox(height: 20),
            Text(
              'UpTodo',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}