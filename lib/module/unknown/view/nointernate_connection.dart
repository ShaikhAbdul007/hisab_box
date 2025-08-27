import 'package:flutter/material.dart';

class NointernateConnection extends StatelessWidget {
  const NointernateConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [Image.asset('assets/connection.png')],
      ),
    );
  }
}
