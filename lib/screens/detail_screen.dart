import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String countryCode;
  const DetailScreen({super.key, required this.countryCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Country Details')),
      body: Center(child: Text('Detail Screen for $countryCode')),
    );
  }
}
