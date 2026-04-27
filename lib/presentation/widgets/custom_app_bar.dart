import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? emoji;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.emoji,
    this.actions,
    this.showBack = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      automaticallyImplyLeading: showBack,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(
              emoji!,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}