import 'package:flutter/material.dart';

class Book with ChangeNotifier {
  final String id;
  final String name;
  final int pages;

  Book({
    required this.id,
    required this.name,
    required this.pages,
  });
}
