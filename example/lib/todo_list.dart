import 'package:equatable/equatable.dart';
import 'package:example/store.dart';
import 'package:flutter/material.dart';
import 'package:slices/slices.dart';

class TodoListSlice extends Equatable {
  final List<String> todos;

  TodoListSlice.fromState(TodoState state) : todos = state.todos;

  @override
  List<Object?> get props => [todos];
}

class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliceWatcher<TodoState, TodoListSlice>(
      slicer: (state) => TodoListSlice.fromState(state),
      builder: (ctx, store, slice) {
        return Container(
          child: Column(
            children: [
              for (var todo in slice.todos)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(todo),
                    GestureDetector(
                      onTap: () {
                        store.dispatch(RemoveTodoAction(todo));
                      },
                      child: Icon(Icons.remove),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
