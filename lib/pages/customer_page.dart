import 'package:flutter/material.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verkäufer"),
      ),
      body: const Center(
        child: Text(
          "Willkommen, Verkäufer!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
