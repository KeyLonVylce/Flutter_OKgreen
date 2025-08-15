import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/core/constants/app_text_styles.dart';
import 'package:okgreen/core/constants/app_dimensions.dart';
import 'package:okgreen/core/constants/app_decorations.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Stack(
            children: [
              // Top Wave background
              ClipPath(
                clipper: TopWaveClipper(),
                child: Container(
                  height: screenHeight * AppDimensions.waveHeightRegister,
                  color: AppColors.primary,
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * AppDimensions.headerTopSpacing),

                      // Header
                      Column(
                        children: [
                          Text('Create Account', style: AppTextStyles.pageTitle),
                          const SizedBox(height: AppDimensions.spacingXS),
                          const Text('Please fill in the form to continue', style: AppTextStyles.pageSubtitle),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingXXL),

                      // Form
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: AppDimensions.formMaxWidth),
                        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                        decoration: AppDecorations.formContainer,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                decoration: AppInputDecorations.baseInputDecoration(
                                  labelText: 'Email Address',
                                  hintText: 'Enter your email',
                                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingMedium),

                              // Username
                              TextFormField(
                                controller: _usernameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Username is required';
                                  }
                                  if (value.length < 3) {
                                    return 'Username must be at least 3 characters';
                                  }
                                  return null;
                                },
                                decoration: AppInputDecorations.baseInputDecoration(
                                  labelText: 'Username',
                                  hintText: 'Choose a username',
                                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingMedium),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                decoration: AppInputDecorations.baseInputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Create a password',
                                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.grey600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXL),

                      // Register Button
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: AppDimensions.formMaxWidth),
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: AppButtonStyles.primaryButton,
                          child: _isLoading
                              ? const SizedBox(
                                  height: AppDimensions.loadingSize,
                                  width: AppDimensions.loadingSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth: AppDimensions.loadingStroke,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                              : const Text('Create Account', style: AppTextStyles.buttonText),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingLarge),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ', style: AppTextStyles.linkPromptText),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Sign In', style: AppTextStyles.linkText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}