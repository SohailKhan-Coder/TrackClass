import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  final List<String> studentNames;

  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.studentNames,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        children: studentNames.isEmpty
            ? [const ListTile(title: Text("No students"))]
            : studentNames.map((name) => ListTile(title: Text(name))).toList(),
      ),
    );
  }
}
