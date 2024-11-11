import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define the TodoItem class
class TodoItem {
  String title;
  bool isCompleted;

  TodoItem({required this.title, this.isCompleted = false});

  // Convert the TodoItem to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  // Create TodoItem from Firestore document
  static TodoItem fromMap(Map<String, dynamic> map) {
    return TodoItem(
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

}

class ToDoListPage extends StatefulWidget {
  String groupId;

  ToDoListPage({super.key, required this.groupId});

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final List<TodoItem> _todoItems = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodoItems(); // Load todo items when the page is initialized
  }

    // Load the to-do list from Firebase
  Future<void> _loadTodoItems() async {
    try {
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
      if (groupDoc.exists && groupDoc.data() != null) {
        var groupData = groupDoc.data() as Map<String, dynamic>;
        List<dynamic> todoList = groupData['todoItems'] ?? [];
        
        setState(() {
          _todoItems.clear();
          _todoItems.addAll(todoList.map((item) => TodoItem.fromMap(item)).toList());
        });
      }
    } catch (e) {
      print('Error loading to-do items: $e');
    }
  }

  // Save the to-do list to Firestore
  Future<void> _saveTodoItems() async {
    try {
      // Save to the group document's 'todoItems' field
      List<Map<String, dynamic>> todoItemsMap = _todoItems.map((item) => item.toMap()).toList();
      await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
        'todoItems': todoItemsMap,
      });
    } catch (e) {
      print('Error saving to-do items: $e');
    }
  }

  // Add to-do item to the list
  void _addTodoItem(String title) {
    setState(() {
      _todoItems.add(TodoItem(title: title));
    });
    _controller.clear();
    _saveTodoItems();
  }

  // Change completion status of the item
  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index].isCompleted = !_todoItems[index].isCompleted;
    });
    _saveTodoItems(); // Save the updated list to Firebase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'New item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _addTodoItem(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoItems.length,
              itemBuilder: (context, index) {
                final item = _todoItems[index];
                return ListTile(
                  leading: Checkbox(
                    value: item.isCompleted,
                    onChanged: (value) {
                      _toggleTodoItem(index);
                    },
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

