import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const LibraryAgentApp());
}

class LibraryAgentApp extends StatelessWidget {
  const LibraryAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: Colors.grey.shade50,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: const Scaffold(body: HomePage()),
    );
  }
}
