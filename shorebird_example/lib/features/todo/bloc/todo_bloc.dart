import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../domain/todo.dart';
import '../data/todo_repository.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodosRepository _repository;

  TodoBloc({TodosRepository? repository}) 
      : _repository = repository ?? TodosRepository(),
        super(const IdleState()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<StartEditingTodoEvent>(_onStartEditingTodo);
    on<CancelEditingEvent>(_onCancelEditing);
    on<SaveEditedTodoEvent>(_onSaveEditedTodo);
    on<ClearCompletedTodosEvent>(_onClearCompletedTodos);
    on<ResetToIdleEvent>(_onResetToIdle);
  }

  // Event handlers
  Future<void> _onLoadTodos(LoadTodosEvent event, Emitter<TodoState> emit) async {
    emit(const LoadingState(operation: 'Loading todos'));
    
    try {
      _repository.initializeWithSampleData();
      final todos = await _repository.getAllTodos();
      emit(IdleState(todos: todos));
    } catch (e) {
      emit(FailedState(
        error: e.toString(),
        operation: 'loading todos',
      ));
    }
  }

  Future<void> _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) async {
    final currentTodos = _getCurrentTodos();
    emit(LoadingState(
      operation: 'Adding todo',
      todos: currentTodos,
    ));
    
    try {
      final newTodo = await _repository.addTodo(
        title: event.title,
        description: event.description,
      );
      
      final updatedTodos = await _repository.getAllTodos();
      emit(SavedState(
        todos: updatedTodos,
        message: 'Todo "${newTodo.title}" added successfully',
        savedTodo: newTodo,
      ));
    } catch (e) {
      emit(FailedState(
        error: e.toString(),
        todos: currentTodos,
        operation: 'adding todo',
      ));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodoEvent event, Emitter<TodoState> emit) async {
    final currentTodos = _getCurrentTodos();
    emit(LoadingState(
      operation: 'Updating todo',
      todos: currentTodos,
    ));
    
    try {
      final updatedTodo = await _repository.updateTodo(event.todo);
      final allTodos = await _repository.getAllTodos();
      
      emit(SavedState(
        todos: allTodos,
        message: 'Todo "${updatedTodo.title}" updated successfully',
        savedTodo: updatedTodo,
      ));
    } catch (e) {
      emit(FailedState(
        error: e.toString(),
        todos: currentTodos,
        operation: 'updating todo',
      ));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodoEvent event, Emitter<TodoState> emit) async {
    final currentTodos = _getCurrentTodos();
    final todoToDelete = currentTodos.firstWhere(
      (todo) => todo.id == event.todoId,
      orElse: () => throw Exception('Todo not found'),
    );
    
    emit(LoadingState(
      operation: 'Deleting todo',
      todos: currentTodos,
    ));
    
    try {
      await _repository.deleteTodo(event.todoId);
      final updatedTodos = await _repository.getAllTodos();
      
      emit(SavedState(
        todos: updatedTodos,
        message: 'Todo "${todoToDelete.title}" deleted successfully',
      ));
    } catch (e) {
      emit(FailedState(
        error: e.toString(),
        todos: currentTodos,
        operation: 'deleting todo',
      ));
    }
  }

  Future<void> _onToggleTodo(ToggleTodoEvent event, Emitter<TodoState> emit) async {
    final currentTodos = _getCurrentTodos();
    emit(LoadingState(
      operation: 'Toggling todo status',
      todos: currentTodos,
    ));
    
    try {
      final toggledTodo = await _repository.toggleTodo(event.todoId);
      final allTodos = await _repository.getAllTodos();
      
      final statusMessage = toggledTodo.isCompleted 
          ? 'marked as completed' 
          : 'marked as pending';
      
      emit(SavedState(
        todos: allTodos,
        message: 'Todo "${toggledTodo.title}" $statusMessage',
        savedTodo: toggledTodo,
      ));
    } catch (e) {
      emit(FailedState(
        error: e.toString(),
        todos: currentTodos,
        operation: 'toggling todo',
      ));
    }
  }

  Future<void> _onStartEditingTodo(StartEditingTodoEvent event, Emitter<TodoState> emit) async {
    final currentState = state;
    if (currentState is IdleState) {
      emit(DevelopmentState(
        todos: currentState.todos,
        editingTodo: event.todo,
        isEditing: true,
      ));
    }
  }

  Future<void> _onCancelEditing(CancelEditingEvent event, Emitter<TodoState> emit) async {
    final currentState = state;
    if (currentState is DevelopmentState) {
      emit(IdleState(todos: currentState.todos));
    }
  }

  Future<void> _onSaveEditedTodo(SaveEditedTodoEvent event, Emitter<TodoState> emit) async {
    final currentState = state;
    if (currentState is! DevelopmentState || currentState.editingTodo == null) {
      emit(const FailedState(error: 'No todo being edited'));
      return;
    }
    
    emit(LoadingState(
      operation: 'Saving edited todo',
      todos: currentState.todos,
    ));
    
    try {
      final editedTodo = currentState.editingTodo!.copyWith(
        title: event.title,
        description: event.description,
      );
      
      final updatedTodo = await _repository.updateTodo(editedTodo);
      final allTodos = await _repository.getAllTodos();
      
      emit(SavedState(
        todos: allTodos,
        message: 'Todo "${updatedTodo.title}" updated successfully',
        savedTodo: updatedTodo,
      ));
    } catch (e) {
      emit(FailedState(
        error: e.toString(),
        todos: currentState.todos,
        operation: 'saving edited todo',
      ));
    }
  }

  Future<void> _onClearCompletedTodos(ClearCompletedTodosEvent event, Emitter<TodoState> emit) async {
    final currentTodos = _getCurrentTodos();
    final completedCount = currentTodos.where((todo) => todo.isCompleted).length;
    
    if (completedCount == 0) {
      emit(IdleState(
        todos: currentTodos,
        message: 'No completed todos to clear',
      ));
      return;
    }
    
    emit(LoadingState(
      operation: 'Clearing completed todos',
      todos: currentTodos,
    ));
    
    try {
      final remainingTodos = await _repository.clearCompletedTodos();
      
      emit(SavedState(
        todos: remainingTodos,
        message: 'Cleared $completedCount completed todo${completedCount > 1 ? 's' : ''}',
      ));
    } catch (e) {
      emit(FailedState(
        error: e.toString(),
        todos: currentTodos,
        operation: 'clearing completed todos',
      ));
    }
  }

  Future<void> _onResetToIdle(ResetToIdleEvent event, Emitter<TodoState> emit) async {
    final currentTodos = _getCurrentTodos();
    emit(IdleState(todos: currentTodos));
  }

  List<Todo> _getCurrentTodos() {
    return switch (state) {
      IdleState(:final todos) => todos,
      LoadingState(:final todos) => todos,
      DevelopmentState(:final todos) => todos,
      SavedState(:final todos) => todos,
      FailedState(:final todos) => todos,
      _ => <Todo>[],
    };
  }
}
