part of 'todo_bloc.dart';

@immutable
abstract class TodoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodoEvent {
  @override
  String toString() => 'LoadTodosEvent';
}

class AddTodoEvent extends TodoEvent {
  final String title;
  final String description;

  const AddTodoEvent({
    required this.title,
    this.description = '',
  });

  @override
  List<Object?> get props => [title, description];

  @override
  String toString() => 'AddTodoEvent(title: $title, description: $description)';
}

class UpdateTodoEvent extends TodoEvent {
  final Todo todo;

  const UpdateTodoEvent({required this.todo});

  @override
  List<Object?> get props => [todo];

  @override
  String toString() => 'UpdateTodoEvent(todo: ${todo.id})';
}

class DeleteTodoEvent extends TodoEvent {
  final String todoId;

  const DeleteTodoEvent({required this.todoId});

  @override
  List<Object?> get props => [todoId];

  @override
  String toString() => 'DeleteTodoEvent(todoId: $todoId)';
}

class ToggleTodoEvent extends TodoEvent {
  final String todoId;

  const ToggleTodoEvent({required this.todoId});

  @override
  List<Object?> get props => [todoId];

  @override
  String toString() => 'ToggleTodoEvent(todoId: $todoId)';
}

class StartEditingTodoEvent extends TodoEvent {
  final Todo todo;

  const StartEditingTodoEvent({required this.todo});

  @override
  List<Object?> get props => [todo];

  @override
  String toString() => 'StartEditingTodoEvent(todo: ${todo.id})';
}

class CancelEditingEvent extends TodoEvent {
  @override
  String toString() => 'CancelEditingEvent';
}

class SaveEditedTodoEvent extends TodoEvent {
  final String title;
  final String description;

  const SaveEditedTodoEvent({
    required this.title,
    this.description = '',
  });

  @override
  List<Object?> get props => [title, description];

  @override
  String toString() => 'SaveEditedTodoEvent(title: $title, description: $description)';
}

class ClearCompletedTodosEvent extends TodoEvent {
  @override
  String toString() => 'ClearCompletedTodosEvent';
}

class ResetToIdleEvent extends TodoEvent {
  @override
  String toString() => 'ResetToIdleEvent';
}
