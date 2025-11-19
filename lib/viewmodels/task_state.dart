import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/task_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> Tasks;
  const TaskLoaded(this.Tasks);

  @override
  List<Object?> get props => [Tasks];
}

class TaskActionSuccess extends TaskState {
  final List<TaskModel> Tasks;
  final String message;

  const TaskActionSuccess(this.Tasks, this.message);

  @override
  List<Object?> get props => [Tasks, message];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
