import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Share',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Change primary color
      ),
      home: GroceryListScreen(),
    );
  }
}

class GroceryListScreen extends StatefulWidget {
  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  List<String> groceryItems = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchGroceryItems();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  void _startTimer() {
    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (Timer timer) {
      _fetchGroceryItems(); // Fetch data every second
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery Share'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _showExitConfirmationDialog(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal, // Change drawer header color
              ),
              child: Text(
                'Grocery List Share',
                style: TextStyle(
                  color: Colors.white, // Change drawer header text color
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('🔴Live Updation In Progress...'), // Customize subheading as needed
            subtitle: Text(groceryItems[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    TextEditingController itemNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
        title: Text('Share Grocery Item'),
          content: TextField(
            controller: itemNameController,
            decoration: InputDecoration(labelText: 'Item Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newItem = itemNameController.text.trim();
                if (newItem.isNotEmpty) {
                  _storeGroceryItem(newItem);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Exit Confirmation'),
          content: Text('Are you sure you want to exit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // You can add additional exit logic here
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _storeGroceryItem(String itemName) async {
    final response = await http.post(
      Uri.parse('https://test11.pythonanywhere.com/store_data'),
      body: {'data': itemName},
    );

    if (response.statusCode == 200) {
      print('Item stored successfully');
    } else {
      print('Failed to store item. Error code: ${response.statusCode}');
    }
  }

  Future<void> _fetchGroceryItems() async {
    final response = await http.get(
      Uri.parse('https://test11.pythonanywhere.com/retrieve_data'),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        groceryItems = List<String>.from(jsonData['data']);
      });
    } else {
      print('Failed to retrieve items. Error code: ${response.statusCode}');
    }
  }
}
