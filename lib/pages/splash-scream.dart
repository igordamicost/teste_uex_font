import 'dart:async';
import 'package:flutter/material.dart';
import 'package:teste_uex_font/pages/login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0; 

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 250), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _opacity = 0.0;
      });
    });

    Future.delayed(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(seconds: 3),
              opacity: _opacity,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Image.asset('assets/uex.png'),
              ),
            ),
            const SizedBox(height: 20),
            const LinearProgressIndicator(color: Color.fromARGB(255, 5, 136, 202)),
          ],
        ),
      ),
    );
  }
}
