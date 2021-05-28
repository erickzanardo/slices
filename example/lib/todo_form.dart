import 'package:example/store.dart';
import 'package:flutter/material.dart';
import 'package:slices/slices.dart';

class TodoForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TodoFormState();
  }
}

class _TodoFormState extends State<TodoForm> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              SlicesProvider.of<TodoState>(context).dispatch(
                AddTodoAction(_controller.text),
              );
              setState(() {
                _controller.text = '';
              });
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }
}
