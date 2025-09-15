import 'package:flutter/material.dart';

class HeaderCloseButton extends StatelessWidget {
  final VoidCallback? onTap;

  const HeaderCloseButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Use IconButton for proper hit target and semantics
          IconButton(
            key: const Key('header_close_button'),
            tooltip: 'Close',
            splashRadius: 20,
            onPressed: () {
              if (onTap != null) {
                onTap!();
              }
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'Start Trial',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
