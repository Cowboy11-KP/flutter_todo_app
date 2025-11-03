import 'package:flutter/material.dart';
import 'package:frontend/views/auth/register_screen.dart';
import 'package:frontend/views/components/custom_app_bar.dart';
import 'package:frontend/views/components/outlined_button.dart';
import 'package:frontend/views/components/primary_button.dart';
import 'package:frontend/views/auth/login_screen.dart';
import 'package:frontend/theme/app_color.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '',
        showBack: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to UpTodo",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 42),
              Text(
               "Please login to your account or create new account to continue",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 370),
              PrimaryButton(
                width: double.infinity,
                text: 'LOGIN', 
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => LoginScreen())
                  );
                },
              ),
              const SizedBox(height: 28),
              OutlinedButtonCustom(
                width: double.infinity,
                text: 'CREATE ACCOUNT',
                onPressed:() {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => RegisterScreen())
                  );
                },
                ),
            ],
          ),
        ),
      ),
    );
  }
}