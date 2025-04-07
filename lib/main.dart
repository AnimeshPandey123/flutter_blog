import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(BlogApp());
}

class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Blog',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlogHomePage(),
    );
  }
}
