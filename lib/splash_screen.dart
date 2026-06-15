import 'dart:math';
import 'package:flutter/material.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _mosqueController;
  late AnimationController _shimmerController;
  late AnimationController _starController;

  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<double> _subtitleFade;
  late Animation<double> _mosqueFade;
  late Animation<Offset> _mosqueSlide;
  late Animation<double> _shimmer;
  late Animation<double> _starFade;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _mosqueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Logo/Bismillah fade
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Title fade
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    // Subtitle fade
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    // Mosque image fade
    _mosqueFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mosqueController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    // Mosque slide up
    _mosqueSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mosqueController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // Shimmer effect for decorative line
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.linear,
      ),
    );

    // Stars twinkling
    _starFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _starController,
        curve: Curves.easeOut,
      ),
    );

    // Start animations with staggering
    _starController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _mosqueController.forward();
    });
    _shimmerController.repeat();

    // Navigate after delay
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainPage(),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _mosqueController.dispose();
    _shimmerController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Deep sky gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0E1A),
                  Color(0xFF0F1832),
                  Color(0xFF162044),
                  Color(0xFF1A2850),
                  Color(0xFF2A3A60),
                ],
                stops: [0.0, 0.25, 0.5, 0.7, 1.0],
              ),
            ),
          ),

          // Animated stars
          FadeTransition(
            opacity: _starFade,
            child: CustomPaint(
              size: screenSize,
              painter: _StarPainter(),
            ),
          ),

          // Crescent moon
          Positioned(
            top: 60,
            right: 40,
            child: FadeTransition(
              opacity: _starFade,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.3),
                      blurRadius: 25,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  color: Color(0xFFFFD54F),
                  size: 30,
                ),
              ),
            ),
          ),

          // Mosque silhouette image positioned at the bottom to avoid RenderFlex overflow
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: screenSize.height * 0.45, // takes 45% of height max
            child: SlideTransition(
              position: _mosqueSlide,
              child: FadeTransition(
                opacity: _mosqueFade,
                child: Stack(
                  children: [
                    // Warm glow behind the mosque
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0, -0.2),
                            radius: 0.8,
                            colors: [
                              const Color(0xFFFFD54F).withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Mosque image with multiply blend to make white background transparent
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.white,
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.15, 0.85, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.asset(
                        'assets/mosque_silhouette.png',
                        width: screenSize.width,
                        height: screenSize.height * 0.45,
                        fit: BoxFit.cover,
                        color: const Color(0xFF2A3A60),
                        colorBlendMode: BlendMode.multiply,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main text and content in a safe Column
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),

                  // Bismillah text
                  FadeTransition(
                    opacity: _logoFade,
                    child: const Text(
                      'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFFFFD54F),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App name
                  FadeTransition(
                    opacity: _titleFade,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFFFFD54F),
                                Colors.white,
                              ],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'AminSim',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Animated shimmer line
                        AnimatedBuilder(
                          animation: _shimmer,
                          builder: (context, child) {
                            return Container(
                              width: 100,
                              height: 1.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                gradient: LinearGradient(
                                  begin: Alignment(_shimmer.value - 1, 0),
                                  end: Alignment(_shimmer.value, 0),
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFFFFD54F)
                                        .withValues(alpha: 0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Text(
                      'Selalu ingat kepada yang maha kuasa',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.55),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Bottom section above the bottom edge but cleanly laid out
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFFFFD54F).withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'v1.0.0',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.25),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints twinkling stars on the background
class _StarPainter extends CustomPainter {
  final _random = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    // Generate stars only in the upper 60% of the screen
    for (int i = 0; i < 50; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height * 0.55;
      final radius = _random.nextDouble() * 1.2 + 0.3;
      final opacity = _random.nextDouble() * 0.5 + 0.15;

      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // A few brighter stars with glow
    for (int i = 0; i < 6; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height * 0.45;
      final radius = _random.nextDouble() * 0.8 + 1.0;

      // Glow
      paint.color = const Color(0xFFFFD54F).withValues(alpha: 0.12);
      canvas.drawCircle(Offset(x, y), radius * 3, paint);

      // Core
      paint.color = Colors.white.withValues(alpha: 0.75);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
