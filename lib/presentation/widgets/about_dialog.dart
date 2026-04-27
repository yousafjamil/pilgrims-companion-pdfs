import 'package:flutter/material.dart';
import '../../app/app_constants.dart';

void showAboutAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Text('🕋'),
          SizedBox(width: 8),
          Text('About'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Version ${AppConstants.appVersion}'),
            const SizedBox(height: 16),
            const Text(
              'Your complete offline guide for Hajj and Umrah pilgrimage.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeature('✅ Complete offline access'),
            _buildFeature('✅ 12 language support'),
            _buildFeature('✅ Step-by-step guides'),
            _buildFeature('✅ Interactive PDF viewer'),
            _buildFeature('✅ Dark mode support'),
            const SizedBox(height: 16),
            Text(
              'May Allah accept your journey!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget _buildFeature(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13),
    ),
  );
}