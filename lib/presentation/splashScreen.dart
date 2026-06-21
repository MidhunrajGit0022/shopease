import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shopease/presentation/main_screen.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.height,
              height: MediaQuery.of(context).size.height,
              child: AnimatedSplashScreen(
                splash: Image.asset(
                  'assets/png/logo.png',
                  height: MediaQuery.of(context).size.height / 4,
                ),
                nextScreen: const MainScreen(),
                splashTransition: SplashTransition.fadeTransition,
                duration: 1000,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
