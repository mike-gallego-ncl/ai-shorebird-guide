part of 'todo_bloc.dart';

@immutable
abstract class TodoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class IdleState extends TodoState {
  final List<Todo> todos;
  final String? message;

  const IdleState({
    this.todos = const [],
    this.message,
  });

  @override
  List<Object?> get props => [todos, message];

  @override
  String toString() => 'IdleState(todos: ${todos.length}, message: $message)';
}

class LoadingState extends TodoState {
  final String operation;
  final List<Todo> todos;

  const LoadingState({
    this.operation = 'Loading',
    this.todos = const [],
  });

  @override
  List<Object?> get props => [operation, todos];

  @override
  String toString() => 'LoadingState(operation: $operation, todos: ${todos.length})';
}

class DevelopmentState extends TodoState {
  final List<Todo> todos;
  final Todo? editingTodo;
  final bool isEditing;

  const DevelopmentState({
    this.todos = const [],
    this.editingTodo,
    this.isEditing = false,
  });

  @override
  List<Object?> get props => [todos, editingTodo, isEditing];

  @override
  String toString() => 'DevelopmentState(todos: ${todos.length}, isEditing: $isEditing, editingTodo: ${editingTodo?.id})';
}

class SavedState extends TodoState {
  final List<Todo> todos;
  final String message;
  final Todo? savedTodo;

  const SavedState({
    required this.todos,
    required this.message,
    this.savedTodo,
  });

  @override
  List<Object?> get props => [todos, message, savedTodo];

  @override
  String toString() => 'SavedState(todos: ${todos.length}, message: $message, savedTodo: ${savedTodo?.id})';
}

class FailedState extends TodoState {
  final List<Todo> todos;
  final String error;
  final String? operation;

  const FailedState({
    required this.error,
    this.todos = const [],
    this.operation,
  });

  @override
  List<Object?> get props => [todos, error, operation];

  @override
  String toString() => 'FailedState(error: $error, operation: $operation, todos: ${todos.length})';
}
