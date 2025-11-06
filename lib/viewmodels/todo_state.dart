import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/todo_model.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoModel> todos;
  const TodoLoaded(this.todos);

  @override
  List<Object?> get props => [todos];
}

class TodoActionSuccess extends TodoState {
  final List<TodoModel> todos;
  final String message;

  const TodoActionSuccess(this.todos, this.message);

  @override
  List<Object?> get props => [todos, message];
}

class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);

  @override
  List<Object?> get props => [message];
}
