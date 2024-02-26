import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/widgets/new_item.dart';
import '../models/grocery_item.dart';

import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final url = Uri.https(
        'flutter-prep-4c5fe-default-rtdb.firebaseio.com', 'shopping_list.json');
    final response = await http.get(url);
    if(response.statusCode>=400){setState(() {
      _error = 'Failed to Fetch data, Please try again later.';
    });}
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((categoryItem) =>
      categoryItem.value.title == item.value['category'])
          .value;
      loadItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      _groceryItems = loadItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context)
        .push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    if(newItem == null){return;}
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _deleteItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    final url = Uri.https(
        'flutter-prep-4c5fe-default-rtdb.firebaseio.com', 'shopping_list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
      showDeleteItemSnackBar();
    }
  }

  void showDeleteItemSnackBar() {
    const snackBar = SnackBar(
      content: Text('Failed to delete item, please try again later.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'Use (+) to add new Items',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
      ),
    );
    if(_isLoading){content = const Center(child: CircularProgressIndicator());}
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _deleteItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    if(_error != null){
      content = Center(
          child: Text(
            _error!,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
          ));
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}