import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/app_constants.dart';
import '../../core/cubit/language_cubit/language_cubit.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/quran_downloader.dart';
import '../widgets/language_card.dart';
import 'download_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() =>
      _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedLanguageCode;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ── Cubit instance ─────────────────────────────────────
  late final LanguageCubit _languageCubit;

  @override
  void initState() {
    super.initState();

    // Initialize cubit
    _languageCubit = LanguageCubit(StorageService.instance);

    // Setup entrance animation
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _languageCubit.close();
    super.dispose();
  }

  // ── Handle Continue ───────────────────────────────────

  Future<void> _handleContinue() async {
    if (_selectedLanguageCode == null) return;

    HapticFeedback.mediumImpact();

    // Save language
    await _languageCubit.saveLanguage(
      _selectedLanguageCode!,
    );

    if (!mounted) return;

    // Start background Quran download
    QuranDownloader().startBackgroundDownload(
      _selectedLanguageCode!,
    );

    // Navigate to download screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DownloadScreen(
          languageCode: _selectedLanguageCode!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return BlocProvider.value(
      value: _languageCubit,
      child: Scaffold(
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ── App Logo ────────────────────────
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        borderRadius:
                            BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🕋',
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Title ───────────────────────────
                    Text(
                      'Select Your Language',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // ── Subtitle ─────────────────────────
                    Text(
                      'Choose your preferred language for the app',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // ── Language Grid ────────────────────
                    Expanded(
                      child: GridView.builder(
                        physics:
                            const BouncingScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: AppConstants
                            .supportedLanguages.length,
                        itemBuilder: (context, index) {
                          final language = AppConstants
                              .supportedLanguages[index];
                          final isSelected =
                              _selectedLanguageCode ==
                                  language.code;

                          // Staggered animation
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ),
                            duration: Duration(
                              milliseconds:
                                  300 + (index * 60),
                            ),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    20 * (1 - value),
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            child: LanguageCard(
                              language: language,
                              isSelected: isSelected,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _selectedLanguageCode =
                                      language.code;
                                });
                                _languageCubit.selectLanguage(
                                  language.code,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Download Info ─────────────────────
                    AnimatedOpacity(
                      opacity:
                          _selectedLanguageCode != null
                              ? 1.0
                              : 0.0,
                      duration:
                          const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '~50 MB guides + Quran downloads in background',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Continue Button ───────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedLanguageCode ==
                                null
                            ? null
                            : _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _selectedLanguageCode == null
                                  ? Colors.grey
                                  : Theme.of(context)
                                      .colorScheme
                                      .primary,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          elevation:
                              _selectedLanguageCode == null
                                  ? 0
                                  : 3,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              _selectedLanguageCode == null
                                  ? 'Select a Language'
                                  : 'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color:
                                    _selectedLanguageCode ==
                                            null
                                        ? Colors.grey.shade600
                                        : Colors.white,
                              ),
                            ),
                            if (_selectedLanguageCode !=
                                null) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}