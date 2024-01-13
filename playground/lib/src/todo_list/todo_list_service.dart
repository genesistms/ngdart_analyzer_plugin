import 'dart:async';

import 'todo_item.dart';

const _mockData = <TodoItem>[];

class TodoListService {
  Future<List<TodoItem>> getTodoList() async => [..._mockData];
}
