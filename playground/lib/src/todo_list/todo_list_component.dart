import 'dart:async';

import 'package:ngdart/angular.dart';

import 'todo_item.dart';
import 'todo_list_service.dart';

@Component(
  selector: 'todo-list',
  styleUrls: ['todo_list_component.css'],
  templateUrl: 'todo_list_component.html',
  directives: [
    NgFor,
    NgIf,
  ],
  providers: [ClassProvider(TodoListService)],
)
class TodoListComponent implements OnInit {
  final TodoListService todoListService;

  List<TodoItem> items = [];

  TodoListComponent(this.todoListService);

  @override
  Future<void> ngOnInit() async {
    items = await todoListService.getTodoList();
  }

  void add(String todo) {
    items.add(TodoItem(todo));
  }

  void toggle(int index, bool done) {
    final item = items[index];
    items[index] = TodoItem(item.value, done: done);
  }

  TodoItem remove(int index) => items.removeAt(index);
}
