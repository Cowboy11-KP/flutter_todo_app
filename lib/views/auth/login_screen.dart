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
import 'package:hive/hive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Login'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BlocConsumer<AuthCubit, AuthState>(
              // 🔹 Chỉ listen khi trạng thái thay đổi sang Authenticated hoặc Error
              listenWhen: (prev, curr) => prev.status != curr.status,
              listener: (context, state) async {
                if (state.status == AuthStatus.authenticated) {
                  var box = Hive.box('settings');
                  await box.put('isRememberMe', _isRememberMe);
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/home');
                } else if (state.status == AuthStatus.error && state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message!), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                // Biến phụ để kiểm tra xem có bất kỳ nút nào đang xoay không
                final bool isEmailLoading = state.status == AuthStatus.loginEmailLoading;
                final bool isGoogleLoading = state.status == AuthStatus.loginGoogleLoading;
                final bool isAnyLoading = isEmailLoading || isGoogleLoading;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email", style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _emailController,
                      hint: "Enter your email",
                      enabled: !isAnyLoading, // Khóa field khi đang load
                    ),
                    const SizedBox(height: 25),
                    Text("Password", style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _passwordController,
                      hint: "••••••••••",
                      isPassword: true,
                      enabled: !isAnyLoading,
                    ),
                    const SizedBox(height: 25),
                    _buildRememberMe(),
                    const SizedBox(height: 70),

                    // 🔹 Nút Login Email
                    isEmailLoading
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            text: 'Login',
                            onPressed: isAnyLoading ? null : _onLoginEmail,
                            width: double.infinity,
                          ),

                    const SizedBox(height: 45),
                    _buildDivider(context),
                    const SizedBox(height: 40),

                    // 🔹 Nút Login Google
                    OutlinedButtonCustom(
                      onPressed: isAnyLoading ? null : () => context.read<AuthCubit>().loginGoogle(),
                      icon: isGoogleLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : SvgPicture.asset('assets/icons/google.svg', width: 24, height: 24),
                      text: 'Login with google',
                      width: double.infinity,
                    ),

                    _buildRegisterRow(context),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onLoginEmail() {
    context.read<AuthCubit>().loginEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          height: 24, width: 24,
          child: Checkbox(
            value: _isRememberMe,
            onChanged: (value) => setState(() => _isRememberMe = value ?? false),
          ),
        ),
        const SizedBox(width: 8),
        const Text("Remember me", style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey, thickness: 1, endIndent: 10)),
        Text("or", style: Theme.of(context).textTheme.bodyLarge),
        const Expanded(child: Divider(color: Colors.grey, thickness: 1, indent: 10)),
      ],
    );
  }

  Widget _buildRegisterRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Don’t have an account?', style: Theme.of(context).textTheme.labelSmall),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
          child: Text('Register', style: Theme.of(context).textTheme.labelMedium),
        )
      ],
    );
  }
}