import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/core/constants/app_text_styles.dart';
import 'package:okgreen/core/constants/app_dimensions.dart';
import 'package:okgreen/core/constants/app_decorations.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';
import 'package:okgreen/service/auth_service.dart'; 

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
  final _confirmPasswordController = TextEditingController(); 
  final AuthService _authService = AuthService(); 

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false; 
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // 🆕
    super.dispose();
  }

  // 🆕 Updated register method dengan AuthService
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final result = await _authService.register(
          name: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

        setState(() => _isLoading = false);

        if (result.success) {
          // Register berhasil
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppColors.primary,
            ),
          );
          
          // Kembali ke login page
          Navigator.pop(context);
        } else {
          // Register gagal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

                              // Username/Name
                              TextFormField(
                                controller: _usernameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Name is required'; // 🆕 Updated label
                                  }
                                  if (value.length < 3) {
                                    return 'Name must be at least 3 characters';
                                  }
                                  return null;
                                },
                                decoration: AppInputDecorations.baseInputDecoration(
                                  labelText: 'Full Name', // 🆕 Updated label
                                  hintText: 'Enter your full name',
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
                              const SizedBox(height: AppDimensions.spacingMedium),

                              // 🆕 Confirm Password
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                decoration: AppInputDecorations.baseInputDecoration(
                                  labelText: 'Confirm Password',
                                  hintText: 'Re-enter your password',
                                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.grey600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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