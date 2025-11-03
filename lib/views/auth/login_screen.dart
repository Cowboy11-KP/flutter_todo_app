import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/viewmodels/auth_cubit.dart';
import 'package:frontend/viewmodels/auth_state.dart';
import 'package:frontend/views/components/Custom_textField.dart';
import 'package:frontend/views/components/custom_app_bar.dart';
import 'package:frontend/views/components/outlined_button.dart';
import 'package:frontend/views/components/primary_button.dart';
import 'package:frontend/views/auth/register_screen.dart';
import 'package:frontend/views/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Login',),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  "Username",
                  style: Theme.of(context).textTheme.bodyLarge
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: "Enter your Username",
                ),
                const SizedBox(height: 25),

                Text(
                   "Password",
                  style: Theme.of(context).textTheme.bodyLarge
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: "••••••••••",
                  obscureText: true,
                ),
                const SizedBox(height: 70),
                PrimaryButton(
                  text: 'Login',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => HomeScreen())
                    );
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: 45),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.grey, // màu đường kẻ
                        thickness: 1,       // độ dày
                        endIndent: 10,      // khoảng cách bên phải
                      ),
                    ),
                    Text(
                      "or",
                      style: Theme.of(context).textTheme.bodyLarge
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 10,         // khoảng cách bên trái
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40,),
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return OutlinedButtonCustom(
                      onPressed: () async {
                        await context.read<AuthCubit>().loginWithGoogle();
                      },
                      icon: Padding(
                        padding: const EdgeInsets.all(1),
                        child: SvgPicture.asset(
                          'asset/icons/google.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      text: 'Login with google',
                      width: double.infinity,
                    );
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don’t have an account?',style: Theme.of(context).textTheme.labelSmall,),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                      },
                      child: Text('Register', style: Theme.of(context).textTheme.labelMedium)
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}