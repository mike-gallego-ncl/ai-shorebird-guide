import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../domain/todo.dart';

class TodosRepository {
  static final TodosRepository _instance = TodosRepository._internal();
  factory TodosRepository() => _instance;
  TodosRepository._internal();

  final List<Todo> _todos = [];
  final Random _random = Random();

  Future<List<Todo>> getAllTodos() async {
    await _simulateDelay();
    return List.from(_todos);
  }

  Future<Todo> addTodo({
    required String title,
    String description = '',
  }) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      throw TodoRepositoryException('Failed to add todo: Network error');
    }

    final todo = Todo(
      id: _generateId(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    _todos.add(todo);
    return todo;
  }

  Future<Todo> updateTodo(Todo updatedTodo) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      throw TodoRepositoryException('Failed to update todo: Network error');
    }

    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index == -1) {
      throw TodoRepositoryException('Todo not found');
    }

    final todoWithUpdatedTime = updatedTodo.copyWith(
      updatedAt: DateTime.now(),
    );

    _todos[index] = todoWithUpdatedTime;
    return todoWithUpdatedTime;
  }

  Future<void> deleteTodo(String todoId) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      throw TodoRepositoryException('Failed to delete todo: Network error');
    }

    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index == -1) {
      throw TodoRepositoryException('Todo not found');
    }

    _todos.removeAt(index);
  }

  Future<Todo> toggleTodo(String todoId) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      throw TodoRepositoryException('Failed to toggle todo: Network error');
    }

    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index == -1) {
      throw TodoRepositoryException('Todo not found');
    }

    final todo = _todos[index];
    final updatedTodo = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );

    _todos[index] = updatedTodo;
    return updatedTodo;
  }

  Future<List<Todo>> clearCompletedTodos() async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      throw TodoRepositoryException('Failed to clear completed todos: Network error');
    }

    _todos.removeWhere((todo) => todo.isCompleted);
    return List.from(_todos);
  }

  Future<Todo?> getTodoById(String todoId) async {
    await _simulateDelay();
    
    try {
      return _todos.firstWhere((todo) => todo.id == todoId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Todo>> searchTodos(String query) async {
    await _simulateDelay();
    
    if (query.isEmpty) return List.from(_todos);
    
    final lowercaseQuery = query.toLowerCase();
    return _todos.where((todo) =>
        todo.title.toLowerCase().contains(lowercaseQuery) ||
        todo.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Stream<List<Todo>> getTodosStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => List.from(_todos));
  }

  Future<void> bulkAddTodos(List<Todo> todos) async {
    await _simulateDelay(multiplier: 2);
    
    if (_shouldSimulateError()) {
      throw TodoRepositoryException('Failed to bulk add todos: Network error');
    }

    _todos.addAll(todos);
  }

  Future<Map<String, int>> getTodoStats() async {
    await _simulateDelay();
    
    final completed = _todos.where((todo) => todo.isCompleted).length;
    final pending = _todos.length - completed;
    
    return {
      'total': _todos.length,
      'completed': completed,
      'pending': pending,
    };
  }

  Future<void> _simulateDelay({int multiplier = 1}) async {
    final delay = _random.nextInt(500) + 200; // 200-700ms
    await Future.delayed(Duration(milliseconds: delay * multiplier));
  }

  bool _shouldSimulateError() {
    return _random.nextDouble() < 0.05; // 5% chance of error
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           _random.nextInt(10000).toString();
  }

  void _seedData() {
    if (_todos.isEmpty) {
      final sampleTodos = [
        Todo(
          id: _generateId(),
          title: 'Welcome to Todo App',
          description: 'This is your first todo item. You can edit, complete, or delete it.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Todo(
          id: _generateId(),
          title: 'Learn Flutter Bloc',
          description: 'Master state management with Bloc pattern',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];
      _todos.addAll(sampleTodos);
    }
  }

  void initializeWithSampleData() {
    _seedData();
  }

  void clearAllData() {
    _todos.clear();
  }
}

class TodoRepositoryException implements Exception {
  final String message;
  const TodoRepositoryException(this.message);

  @override
  String toString() => 'TodoRepositoryException: $message';
}