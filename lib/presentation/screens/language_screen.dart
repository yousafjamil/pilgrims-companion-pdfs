import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/app_constants.dart';
import '../../core/cubit/language_cubit/language_cubit.dart';
import '../../core/cubit/language_cubit/language_state.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/quran_downloader.dart';
import '../widgets/language_card.dart';
import 'download_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguageCode;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    
    return BlocProvider(
      create: (context) => LanguageCubit(StorageService.instance),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // App Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      '🕋',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Select Your Language',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Choose your preferred language for the app',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Language Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: AppConstants.supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final language = AppConstants.supportedLanguages[index];
                      final isSelected = _selectedLanguageCode == language.code;
                      
                      return LanguageCard(
                        language: language,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedLanguageCode = language.code;
                          });
                          context.read<LanguageCubit>().selectLanguage(language.code);
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Download Size Info
                if (_selectedLanguageCode != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Estimated download: ~50 MB + Quran (~100 MB in background)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Continue Button
                BlocBuilder<LanguageCubit, LanguageState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedLanguageCode == null 
                            ? null 
                            : () async {
                                // Save language
                                await context.read<LanguageCubit>()
                                    .saveLanguage(_selectedLanguageCode!);
                                
                                if (!mounted) return;
                                
                                // 🚀 START BACKGROUND QURAN DOWNLOAD
                                print('🚀 Starting background Quran download for: $_selectedLanguageCode');
                                QuranDownloader().startBackgroundDownload(_selectedLanguageCode!);
                                
                                // Navigate to download screen (for small PDFs)
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => DownloadScreen(
                                      languageCode: _selectedLanguageCode!,
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedLanguageCode == null
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}