import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({super.key, required this.onInitializationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoGlowAnimation;
  late AnimationController _particlesController;

  late AnimationController _textController;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  final int numParticles = 120;
  final List<Offset> particles = [];

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoScaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _logoGlowAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoController.forward();

    // Particle animation
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < numParticles; i++) {
      particles.add(Offset(Random().nextDouble(), Random().nextDouble()));
    }

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _textFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_textController);
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Delay text appearance by 2 seconds
    Future.delayed(const Duration(seconds: 1), () {
      _textController.forward();
    });

    // Delay before moving to main screen
    Future.delayed(const Duration(seconds: 2), () {
      widget.onInitializationComplete();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particlesController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _particlesController,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(
              particles: particles,
              animation: _particlesController,
              size: size,
            ),
            child: Center(
              child: ScaleTransition(
                scale: _logoScaleAnimation,
                child: AnimatedBuilder(
                  animation: _logoGlowAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(
                              _logoGlowAnimation.value,
                            ),
                            Colors.cyanAccent.withOpacity(
                              _logoGlowAnimation.value,
                            ),
                            Colors.white.withOpacity(0.1),
                          ],
                          stops: const [0, 0.6, 1],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.5),
                            blurRadius: 40 * _logoGlowAnimation.value,
                            spreadRadius: 10 * _logoGlowAnimation.value,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.memory, // Brain-like circuit
                        size: 100,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: FadeTransition(
        opacity: _textFadeAnimation,
        child: SlideTransition(
          position: _textSlideAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "NeuraLens",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Vision Beyond Intelligence",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Offset> particles;
  final Animation<double> animation;
  final Size size;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      final offset = Offset(
        (p.dx * size.width + sin(animation.value * 2 * pi + p.dy * 10) * 50) %
            size.width,
        (p.dy * size.height + cos(animation.value * 2 * pi + p.dx * 10) * 50) %
            size.height,
      );

      paint.color = Colors.cyanAccent.withOpacity(
        0.2 + 0.8 * Random().nextDouble(),
      );
      canvas.drawCircle(offset, 2 + Random().nextDouble() * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
