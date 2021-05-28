import 'package:example/store.dart';
import 'package:example/todo_form.dart';
import 'package:example/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:slices/slices.dart';

final store = SlicesStore<TodoState>(TodoState());

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slices',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoApp(),
    );
  }
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SlicesProvider<TodoState>(
          store: store,
          child: Center(
            child: Column(
              children: [
                Expanded(child: TodoList()),
                TodoForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
