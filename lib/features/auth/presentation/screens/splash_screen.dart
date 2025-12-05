import 'package:flutter/material.dart';

// Assuming LoginScreen is the next logical step after splash
import 'package:plant_care_app/features/auth/presentation/screens/login_screen.dart';
// Assuming colors are imported from the theme file
import 'package:plant_care_app/core/theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PlantPulse Logo - stylized text for now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_florist, color: Theme.of(context).primaryColor, size: 40), // Placeholder for leaf icon
                  SizedBox(width: 8),
                  Text(
                    'Khodra',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineLarge?.color, // Use theme color
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Smart plant care',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).hintColor, // Using accent color for subtitle
                ),
              ),
              const SizedBox(height: 80), // Space before the button
              // Get Started Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the next screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const LoginScreen(), // Or HomeScreen
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get Started',
                      style: TextStyle(fontSize: 18, color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve(MaterialState.values.toSet())), // Use theme color
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.arrow_forward, color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve(MaterialState.values.toSet())), // Use theme color
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
