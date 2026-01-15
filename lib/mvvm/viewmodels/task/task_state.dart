import 'package:equatable/equatable.dart';
import 'package:frontend/mvvm/models/task/task_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  const TaskLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskActionSuccess extends TaskState {
  final List<TaskModel> tasks;
  final String message;

  const TaskActionSuccess(this.tasks, this.message);

  @override
  List<Object?> get props => [tasks, message];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
