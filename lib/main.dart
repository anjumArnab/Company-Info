import 'package:flutter/material.dart';
import 'package:rest_api_dio/screens/home_page.dart';

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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Rest Api Integration using Dio",
      home: HomePage(),
    );
  }
}