import 'package:flutter/material.dart';
import 'package:gaming_center/core/constants/colors.dart';
import 'package:gaming_center/core/constants/images.dart';
import 'package:gaming_center/features/billing/presentation/dashboard.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1220), // dark gaming vibe
      body: Center(
        child: Container(
          width: size.width > 600 ? 420 : size.width * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1E36),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 18,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  
                  borderRadius: BorderRadius.circular(80),
                  child: Image.asset(AppImages.logo,fit: BoxFit.cover,))
              ),

              const SizedBox(height: 16),

              // App Name
              const Text(
                'BOOTCAMP',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Login to manage devices & sessions',
                style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              // Username
              TextField(
                style: const TextStyle(color:AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF25284A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password
              TextField(
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF25284A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => DashboardScreen(),), (route) => false,);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary
                    ),
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
