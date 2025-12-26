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
      appBar: const CustomAppBar(title: 'Register'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BlocConsumer<AuthCubit, AuthState>(
              listenWhen: (prev, curr) => prev.status != curr.status,
              listener: (context, state) {
                if (state.status == AuthStatus.authenticated) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                } else if (state.status == AuthStatus.error && state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message!), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                // Kiểm tra các trạng thái loading
                final bool isRegisterLoading = state.status == AuthStatus.registerLoading;
                final bool isGoogleLoading = state.status == AuthStatus.loginGoogleLoading;
                final bool isAnyLoading = isRegisterLoading || isGoogleLoading;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Username"),
                    CustomTextField(
                      controller: _usernameController,
                      hint: "Enter your Username",
                      enabled: !isAnyLoading,
                    ),
                    const SizedBox(height: 25),

                    _buildLabel("Email"),
                    CustomTextField(
                      controller: _emailController,
                      hint: "Enter your email",
                      enabled: !isAnyLoading,
                    ),
                    const SizedBox(height: 25),

                    _buildLabel("Password"),
                    CustomTextField(
                      controller: _passwordController,
                      hint: "••••••••••",
                      isPassword: true,
                      enabled: !isAnyLoading,
                    ),
                    const SizedBox(height: 25),

                    _buildLabel("Confirm Password"),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hint: "••••••••••",
                      isPassword: true,
                      enabled: !isAnyLoading,
                    ),
                    const SizedBox(height: 70),

                    // 🔹 Nút Register chính
                    isRegisterLoading
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            text: 'Register',
                            onPressed: isAnyLoading ? null : _onRegister,
                            width: double.infinity,
                          ),

                    const SizedBox(height: 45),
                    _buildDivider(context),
                    const SizedBox(height: 40),

                    // 🔹 Nút Login with Google (vẫn giữ ở màn đăng ký nếu cần)
                    OutlinedButtonCustom(
                      onPressed: isAnyLoading ? null : () => context.read<AuthCubit>().loginGoogle(),
                      icon: isGoogleLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : SvgPicture.asset('assets/icons/google.svg', width: 24, height: 24),
                      text: 'Login with google',
                      width: double.infinity,
                    ),

                    _buildLoginRow(context),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onRegister() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu xác nhận không khớp!")),
      );
      return;
    }
    context.read<AuthCubit>().registerEmail(
          userName: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
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

  Widget _buildLoginRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account?', style: Theme.of(context).textTheme.labelSmall),
        TextButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          child: Text('Login', style: Theme.of(context).textTheme.labelMedium),
        )
      ],
    );
  }
}