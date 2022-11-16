import 'package:flutter/material.dart';
import 'package:livros/models/book.dart';
import 'package:livros/models/book_list.dart';
import 'package:livros/utils/app_routes.dart';
import 'package:provider/provider.dart';

class BookFormPage extends StatefulWidget {
  const BookFormPage({Key? key}) : super(key: key);

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _pagesFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};

  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final book = arg as Book;
        _formData['id'] = book.id;
        _formData['name'] = book.name;
        _formData['pages'] = book.pages;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pagesFocus.dispose();
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    setState(() => _isLoading = true);

    try {
      await Provider.of<BookList>(
        context,
        listen: false,
      ).saveBook(_formData);

      Navigator.of(context).pushNamed(AppRoutes.home);
    } catch (error) {
      print(error);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro para salvar o produto.'),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulário de Livro'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formData['name']?.toString(),
                      decoration: const InputDecoration(labelText: 'Nome'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_pagesFocus);
                      },
                      onSaved: (name) => _formData['name'] = name ?? '',
                      validator: (_name) {
                        final name = _name ?? '';
                        if (name.trim().isEmpty) {
                          return 'Nome é obrigatório.';
                        }
                        if (name.trim().length < 3) {
                          return 'Nome precisa no mínimo de 3 letras.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['pages']?.toString(),
                      decoration: const InputDecoration(
                          labelText: 'Quantidade de Páginas'),
                      textInputAction: TextInputAction.next,
                      focusNode: _pagesFocus,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      onSaved: (pages) =>
                          _formData['pages'] = int.parse(pages ?? '0'),
                      validator: (_pages) {
                        final pagesString = _pages ?? '';
                        final pages = int.tryParse(pagesString) ?? -1;

                        if (pages <= 0) {
                          return 'Quantidade de páginas inválida.';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
