import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/viewmodels/auth_cubit.dart';
import 'package:frontend/viewmodels/auth_state.dart';
import 'package:frontend/views/components/Custom_textField.dart';
import 'package:frontend/views/components/custom_app_bar.dart';
import 'package:frontend/views/components/outlined_button.dart';
import 'package:frontend/views/components/primary_button.dart';
import 'package:frontend/views/auth/login_screen.dart';
import 'package:frontend/views/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Register',),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Username",
                  style: Theme.of(context).textTheme.bodyLarge
                ),
                CustomTextField(
                  controller: _usernameController,
                  hint: "Enter your Username",
                ),
                const SizedBox(height: 25),

                Text(
                  "Email",
                  style: Theme.of(context).textTheme.bodyLarge
                ),
                CustomTextField(
                  controller: _emailController,
                  hint: "Enter your email",
                ),
                const SizedBox(height: 25),

                Text(
                  "Password",
                  style: Theme.of(context).textTheme.bodyLarge
                ),
                CustomTextField(
                  controller: _passwordController,
                  hint: "••••••••••",
                  obscureText: true,
                ),
                const SizedBox(height: 25),

                Text(
                   "Confirm Password",
                  style: Theme.of(context).textTheme.bodyLarge
                ),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hint: "••••••••••",
                  obscureText: true,
                ),
                const SizedBox(height: 70),

                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is Authenticated) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    } else if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return PrimaryButton(
                      text: 'Register',
                      onPressed: () {
                      },
                      width: double.infinity,
                    );
                  }
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
                    if (state is Authenticated) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    } else if (state is AuthError) {
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
                        await context.read<AuthCubit>().loginGoogle();
                      },
                      icon: Padding(
                        padding: const EdgeInsets.all(1),
                        child: SvgPicture.asset(
                          'assets/icons/google.svg',
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
                    Text('Alrealy have an account?',style: Theme.of(context).textTheme.labelSmall,),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                      },
                      child: Text('Login', style: Theme.of(context).textTheme.labelMedium)
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