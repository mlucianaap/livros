import 'package:flutter/material.dart';
import 'package:livros/components/book_item.dart';
import 'package:livros/models/book_list.dart';
import 'package:livros/utils/app_routes.dart';
import 'package:provider/provider.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<BookList>(
      context,
      listen: false,
    ).loadBooks();
  }

  Future<void> _refreshBooks(BuildContext context) {
    return Provider.of<BookList>(
      context,
      listen: false,
    ).loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    final BookList books = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Livros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.bookForm);
            },
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshBooks(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: books.itemsCount,
            itemBuilder: (ctx, i) => Column(
              children: [
                BookItem(books.items[i]),
                const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
