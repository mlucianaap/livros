import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livros/exceptions/http_exception.dart';
import 'package:livros/models/book.dart';
import 'package:livros/utils/constants.dart';

class BookList with ChangeNotifier {
  final List<Book> _items = [];

  List<Book> get items => [..._items];

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadBooks() async {
    _items.clear();

    final response = await http.get(
      Uri.parse('${Constants.baseUrl}.json'),
    );
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    print(data);
    data.forEach((bookId, bookData) {
      _items.add(
        Book(
          id: bookId,
          name: bookData['name'],
          pages: bookData['pages'],
        ),
      );
    });
    notifyListeners();
  }

  Future<void> saveBook(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final book = Book(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      pages: data['pages'] as int,
    );

    if (hasId) {
      return updateBook(book);
    } else {
      return addBook(book);
    }
  }

  Future<void> addBook(Book book) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}.json'),
      body: jsonEncode(
        {
          "name": book.name,
          "pages": book.pages,
        },
      ),
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(Book(
      id: id,
      name: book.name,
      pages: book.pages,
    ));
    notifyListeners();
  }

  Future<void> updateBook(Book book) async {
    int index = _items.indexWhere((p) => p.id == book.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse('${Constants.baseUrl}/${book.id}.json'),
        body: jsonEncode(
          {
            "name": book.name,
            "pages": book.pages,
          },
        ),
      );

      _items[index] = book;
      notifyListeners();
    }
  }

  Future<void> removeBook(Book book) async {
    int index = _items.indexWhere((p) => p.id == book.id);

    if (index >= 0) {
      final book = _items[index];
      _items.remove(book);
      notifyListeners();

      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}/${book.id}.json'),
      );

      if (response.statusCode >= 400) {
        _items.insert(index, book);
        notifyListeners();
        throw HttpException(
          msg: 'Não foi possível excluir o produto.',
          statusCode: response.statusCode,
        );
      }
    }
  }
}
