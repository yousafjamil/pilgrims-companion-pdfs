import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/download_service.dart';
import 'language_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation Controllers ───────────────────────────────
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  // ── Animations ──────────────────────────────────────────
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Logo animations
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Text animations
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Pulse animation
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start sequence
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Start logo animation
    await _logoController.forward();

    // Start text animation
    await _textController.forward();

    // Navigate after delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final storageService = StorageService.instance;
    final selectedLanguage = storageService.getLanguage();

    if (!mounted) return;

    if (selectedLanguage != null) {
      final downloadService = DownloadService();
      final isDownloaded = await downloadService
          .isLanguageContentDownloaded(selectedLanguage);

      if (!mounted) return;

      _navigateTo(
        isDownloaded
            ? const HomeScreen()
            : const LanguageScreen(),
      );
    } else {
      _navigateTo(const LanguageScreen());
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration:
            const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Full screen immersive
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A3D28),
              const Color(0xFF2D5F3F),
              const Color(0xFF3D7A52),
              const Color(0xFFD4AF37).withOpacity(0.3),
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Background Pattern ─────────────────────
            _buildBackgroundPattern(),

            // ── Main Content ───────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: ScaleTransition(
                            scale: _pulseScale,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: _buildLogo(),
                  ),

                  const SizedBox(height: 40),

                  // Text Content
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: _buildTextContent(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Section ─────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textFade,
                child: _buildBottomSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Background Pattern ──────────────────────────────────

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _PatternPainter(),
      ),
    );
  }

  // ── Logo ────────────────────────────────────────────────

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '🕋',
          style: TextStyle(fontSize: 70),
        ),
      ),
    );
  }

  // ── Text Content ────────────────────────────────────────

  Widget _buildTextContent() {
    return Column(
      children: [
        const Text(
          'Pilgrim\'s Companion',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Text(
            'Your Complete Hajj & Umrah Guide',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Arabic Bismillah
        const Text(
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  // ── Bottom Section ──────────────────────────────────────

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        children: [
          // Loading dots
          _buildLoadingDots(),

          const SizedBox(height: 16),

          const Text(
            'Preparing your journey...',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 30),

          // Gold divider
          Container(
            width: 60,
            height: 2,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFFD4AF37),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading Dots ────────────────────────────────────────

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue =
                (_pulseController.value - delay)
                    .clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.3 + (animValue * 0.7),
                ),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Background Pattern Painter ────────────────────────────

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw geometric pattern
    const spacing = 60.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          30,
          paint,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: 40,
            height: 40,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      false;
}