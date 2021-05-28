import 'package:slices/slices.dart';

class TodoState extends SlicesState {
  final List<String> todos;

  TodoState({this.todos = const []});
}

class AddTodoAction extends SlicesAction<TodoState> {
  final String todo;

  AddTodoAction(this.todo);

  TodoState perform(SlicesStore<TodoState> store, TodoState state) {
    return TodoState(
      todos: [
        ...state.todos,
        todo,
      ],
    );
  }
}

class RemoveTodoAction extends SlicesAction<TodoState> {
  final String todo;

  RemoveTodoAction(this.todo);

  TodoState perform(SlicesStore<TodoState> store, TodoState state) {
    return TodoState(
      todos: [
        ...state.todos.where((curr) => curr != todo),
      ],
    );
  }
}
