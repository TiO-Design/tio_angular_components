import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/laminate/overlay/overlay.dart';
import 'package:angular_components/laminate/overlay/zindexer.dart';
import 'package:angular_components/laminate/ruler/dom_ruler.dart';
import 'package:angular_components/utils/angular/imperative_view/imperative_view.dart';
import 'package:angular_components/utils/angular/managed_zone/angular_2.dart';
import 'package:angular_components/utils/browser/dom_service/angular_2.dart';

import 'todo_list_service.dart';

@Component(
  selector: 'todo-list',
  styleUrls: ['todo_list_component.css'],
  templateUrl: 'todo_list_component.html',
  directives: [
    MaterialCheckboxComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    MaterialButtonComponent,
    MaterialPopupComponent,
    materialInputDirectives,
    PopupSourceDirective,
    NgFor,
    NgIf,
  ],
  providers: [ClassProvider(TodoListService), popupBindings],
)
class TodoListComponent implements OnInit {
  var popupVisible = false;
  final TodoListService todoListService;

  List<String> items = [];
  String newTodo = '';

  TodoListComponent(this.todoListService);

  @override
  Future<Null> ngOnInit() async {
    items = await todoListService.getTodoList();
  }

  void add() {
    items.add(newTodo);
    newTodo = '';
  }

  String remove(int index) => items.removeAt(index);
}
