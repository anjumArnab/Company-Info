import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/homepage.dart';

void main() {
  runApp(const RestApiDio());
}

class RestApiDio extends StatefulWidget {
  const RestApiDio({super.key});

  @override
  State<RestApiDio> createState() => _RestApiDioState();
}

class _RestApiDioState extends State<RestApiDio> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "REST API Integration with Dio",
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const Homepage(),
    );
  }
}
