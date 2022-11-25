import 'package:flutter/material.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reportes',
          style: TextStyle(fontSize: 30.00, fontWeight: FontWeight.bold)),
    );
  }
}
