import 'package:flutter/material.dart';
import 'package:manager_web/screens/dashboard_screen.dart';
import 'package:manager_web/widgets/powered_by_cactus.dart';
import 'package:manager_web/services/api_service.dart';
import 'package:manager_web/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await ApiService.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result['success'] == true) {
            // Check if user is manager
            final employeeData = result['data']['employee'];
            if (employeeData['role'] == 'manager') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const DashboardScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'هذا الحساب ليس حساب مدير',
                    style: AppTheme.body.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.systemRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'فشل تسجيل الدخول',
                  style: AppTheme.body.copyWith(color: Colors.white),
                ),
                backgroundColor: AppTheme.systemRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'حدث خطأ: ${e.toString()}',
                style: AppTheme.body.copyWith(color: Colors.white),
              ),
              backgroundColor: AppTheme.systemRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Title
                  Text(
                    'تسجيل دخول المدير',
                    textAlign: TextAlign.center,
                    style: AppTheme.title1.copyWith(
                      color: AppTheme.label,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'منصة الاستلامات الموحدة',
                    textAlign: TextAlign.center,
                    style: AppTheme.subhead.copyWith(
                      color: AppTheme.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing40),

                  // Login Form Card (iOS Inset Grouped Style)
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryBackground,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Username Field
                          TextFormField(
                            controller: _usernameController,
                            textDirection: TextDirection.rtl,
                            style: AppTheme.body.copyWith(
                              color: AppTheme.label,
                            ),
                            decoration: InputDecoration(
                              labelText: 'اسم المستخدم',
                              hintText: 'أدخل اسم المستخدم',
                              hintTextDirection: TextDirection.rtl,
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: AppTheme.systemBlue,
                              ),
                              labelStyle: AppTheme.subhead.copyWith(
                                color: AppTheme.secondaryLabel,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال اسم المستخدم';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacing16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textDirection: TextDirection.rtl,
                            style: AppTheme.body.copyWith(
                              color: AppTheme.label,
                            ),
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              hintText: 'أدخل كلمة المرور',
                              hintTextDirection: TextDirection.rtl,
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppTheme.systemBlue,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppTheme.secondaryLabel,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              labelStyle: AppTheme.subhead.copyWith(
                                color: AppTheme.secondaryLabel,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Login Button (iOS Style)
                  SizedBox(
                    height: 50, // iOS standard button height
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.systemBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'تسجيل الدخول',
                              style: AppTheme.headline.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  // Powered by Cactus
                  const SizedBox(height: AppTheme.spacing32),
                  const PoweredByCactus(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
