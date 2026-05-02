import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/services/download_service.dart';

class TestPdfScreen extends StatelessWidget {
  const TestPdfScreen({super.key});

  Future<void> _createSamplePdf() async {
    try {
      final downloadService = DownloadService();
      final pdfsDir = await downloadService.getPdfsDirectory('en');
      
      // Create a dummy PDF file for testing
      final file = File('$pdfsDir/umrah_guide_en.pdf');
      
      // For now, we'll create an empty file
      // In real scenario, you'd download from GitHub
      await file.writeAsString('Sample PDF content');
      
      print('Sample PDF created at: ${file.path}');
    } catch (e) {
      print('Error creating sample PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test PDF Setup')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is a test screen to setup sample PDFs'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _createSamplePdf();
              },
              child: const Text('Create Sample PDF Directory'),
            ),
          ],
        ),
      ),
    );
  }
}