import 'package:flutter/material.dart';
import 'package:livros/models/book_list.dart';
import 'package:livros/pages/books_page.dart';
import 'package:livros/pages/form.dart';
import 'package:livros/utils/app_routes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BookList(),
        ),
      ],
      child: MaterialApp(
        title: 'CRUD Livros',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.indigo,
          ),
        ),
        routes: {
          AppRoutes.home: (ctx) => const BooksPage(),
          AppRoutes.bookForm: (ctx) => const BookFormPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
