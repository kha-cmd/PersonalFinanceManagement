import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final Random random = Random();
  final int numParticles = 20;
  List<Offset> particlePositions = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < numParticles; i++) {
      particlePositions.add(Offset(random.nextDouble(), random.nextDouble()));
    }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        particlePositions = particlePositions.map((p) {
          double dx = p.dx + (random.nextDouble() - 0.5) * 0.02;
          double dy = p.dy + (random.nextDouble() - 0.5) * 0.02;
          return Offset(dx.clamp(0.0, 1.0), dy.clamp(0.0, 1.0));
        }).toList();
      });
    });

    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildParticles(double width, double height) {
    return Stack(
      children: particlePositions.map((p) {
        return Positioned(
          left: p.dx * width,
          top: p.dy * height,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 2,
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          /// 🌿 Nature Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3F2E1), // bamboo mist
                  Color(0xFFCDE4C7), // soft plant green
                  Color(0xFFAECFAF), // muted natural green
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// ✨ Floating particles
          _buildParticles(size.width, size.height),

          /// 📌 Top-right Logo + Text
          Positioned(
            top: 50,
            right: 20,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 70,
                  height: 30,
                ),
                //const SizedBox(height: 6),
                const Text(
                  "ChatCheng Louy",
                  style: TextStyle(
                    color: Color(0xFF2E5D38), // dark soft green
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          /// 🌟 Center Animated Logo & Title
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/image.png',
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    /// 🇬🇧 English title
                    const Text(
                      'Personal Finance Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF2E5D38), // main dark soft green
                        fontSize: 18,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 9),

                    const Text(
                      'Income & Expense Tracking',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4C7A55), // lighter soft green
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
