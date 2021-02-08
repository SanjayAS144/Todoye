import 'package:flutter/material.dart';
import 'package:todoey/screen/todo_list.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Todoey",
      home: ToDoList(),
    );
  }
}

