import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9E3D9),
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.25))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco, size: 14, color: Color(0xFF4E7A43)),
          const SizedBox(width: 5),
          Text(
            'LeafCloud',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          Text('  ·  Smart Hydroponics Monitoring', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          Text('  ·  © 2026', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
