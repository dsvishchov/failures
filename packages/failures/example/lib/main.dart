import 'package:failures/failures.dart';
import 'package:flutter/material.dart';

part 'main.g.dart';

@FailureEnum()
enum ApiError {
  generic,
  notFound;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: page(context),
        ),
      ),
    );
  }

  Widget? page(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8.0,
        children: [
          const Text('Example'),
        ],
      ),
    );
  }
}
