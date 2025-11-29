import 'package:flutter/material.dart';

class SimpleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const SimpleCard({super.key, required this.title, required this.subtitle, this.onTap, required IconData icon, required Color color, required Color textColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}