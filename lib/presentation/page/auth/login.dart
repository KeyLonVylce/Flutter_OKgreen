import 'package:flutter/material.dart';
import 'package:okgreen/core/constants/app_colors.dart';
import 'package:okgreen/core/constants/app_text_styles.dart';
import 'package:okgreen/core/constants/app_dimensions.dart';
import 'package:okgreen/core/constants/app_decorations.dart';
import 'package:okgreen/presentation/widget/top_wave.dart';
import 'package:okgreen/presentation/page/detail_toko/beranda_page.dart';
import 'package:okgreen/service/auth_service.dart';
import 'register.dart';

class WaveLoginScreen extends StatefulWidget {
  const WaveLoginScreen({super.key});

  @override
  _WaveLoginScreenState createState() => _WaveLoginScreenState();
}

class _WaveLoginScreenState extends State<WaveLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // 🆕 Instance AuthService
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  
  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateLogin(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    // Update validation untuk email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // 🆕 Updated login method dengan AuthService
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final result = await _authService.login(
          email: _loginController.text.trim(),
          password: _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (result.success) {
          // Login berhasil
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppColors.primary,
            ),
          );
          
          // Navigate to home
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => BerandaPage())
          );
        } else {
          // Login gagal
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

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Forgot Password'),
        content: Text('Password reset functionality will be implemented here.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Stack(
            children: [
              // Wave background
              ClipPath(
                clipper: TopWaveClipper(),
                child: Container(
                  height: screenHeight * AppDimensions.waveHeightLogin,
                  decoration: AppDecorations.waveGradient,
                ),
              ),

              // Login content
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * AppDimensions.headerTopSpacing),
                      
                      // Header
                      Column(
                        children: [
                          Text('Welcome Back!', style: AppTextStyles.pageTitle),
                          SizedBox(height: AppDimensions.spacingXS),
                          Text('Sign in to continue to your account', style: AppTextStyles.pageSubtitle),
                        ],
                      ),
                      
                      SizedBox(height: AppDimensions.spacingXXL),

                      // Login Form
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(maxWidth: AppDimensions.formMaxWidth),
                        padding: EdgeInsets.all(AppDimensions.paddingMedium),
                        decoration: AppDecorations.formContainer,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email Field (Updated label)
                              TextFormField(
                                controller: _loginController,
                                keyboardType: TextInputType.emailAddress, // 🆕 Email keyboard
                                validator: _validateLogin,
                                decoration: AppInputDecorations.baseInputDecoration(
                                  labelText: 'Email Address', // 🆕 Updated label
                                  hintText: 'Enter your email address',
                                  prefixIcon: Icon(Icons.email_outlined), // 🆕 Email icon
                                ),
                              ),
                              
                              SizedBox(height: AppDimensions.spacingMedium),
                              
                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                validator: _validatePassword,
                                decoration: AppInputDecorations.baseInputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: AppDimensions.spacingSmall),
                              
                              // Remember Me & Forgot Password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) => setState(() => _rememberMe = value!),
                                        activeColor: AppColors.primary,
                                      ),
                                      Text('Remember me', style: AppTextStyles.rememberMeText),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: _showForgotPasswordDialog,
                                    child: Text('Forgot Password?', style: AppTextStyles.forgotPasswordText),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: AppDimensions.spacingLarge),
                              
                              // Login Button
                              SizedBox(
                                height: AppDimensions.buttonHeight,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: AppButtonStyles.primaryButton,
                                  child: _isLoading
                                      ? SizedBox(
                                          height: AppDimensions.loadingSize,
                                          width: AppDimensions.loadingSize,
                                          child: CircularProgressIndicator(
                                            strokeWidth: AppDimensions.loadingStroke,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                          ),
                                        )
                                      : Text('Sign In', style: AppTextStyles.buttonText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppDimensions.spacingXL),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.grey800)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingSmall),
                            child: Text('OR', style: AppTextStyles.dividerText),
                          ),
                          Expanded(child: Divider(color: AppColors.grey800)),
                        ],
                      ),

                      SizedBox(height: AppDimensions.spacingLarge),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: AppTextStyles.linkPromptText),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
                            },
                            child: Text('Sign Up', style: AppTextStyles.linkText),
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