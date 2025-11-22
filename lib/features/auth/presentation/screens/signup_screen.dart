import 'package:flutter/material.dart';
import 'package:plant_care_app/core/theme/colors.dart'; // Import colors
import 'package:plant_care_app/features/auth/presentation/screens/login_screen.dart';
import 'package:plant_care_app/features/home/presentation/screens/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  void _signup() {
    // TODO: Implement Google signup logic
    // For now, navigate to HomeScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_florist, color: Theme.of(context).primaryColor, size: 40),
                  const SizedBox(width: 8),
                  Text(
                    'Khodra',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Create a new account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 48),

              // Google Sign Up Button
              ElevatedButton.icon(
                onPressed: _signup,
                icon: const Icon(Icons.login), // Using generic login icon as placeholder for Google
                label: const Text(
                  'Sign up with Google',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Login Link
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
