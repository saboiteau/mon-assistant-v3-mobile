import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

void main() {
  runApp(const AssistantV3App());
}

class AssistantV3App extends StatelessWidget {
  const AssistantV3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Assistant IA V3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF135BEC),
        scaffoldBackgroundColor: const Color(0xFF0A0A14),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF135BEC),
          secondary: Color(0xFFFF8C42),
          surface: Color(0xFF1E1B4B),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
