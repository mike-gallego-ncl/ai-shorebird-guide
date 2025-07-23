import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../domain/todo.dart';

class TodoComponent extends StatefulWidget {
  const TodoComponent({super.key});

  @override
  State<TodoComponent> createState() => _TodoComponentState();
}

class _TodoComponentState extends State<TodoComponent> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _editTitleController = TextEditingController();
  final _editDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(LoadTodosEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _editTitleController.dispose();
    _editDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Todo App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              final todos = _getTodosFromState(state);
              final hasCompleted = todos.any((todo) => todo.isCompleted);
              
              if (!hasCompleted) return const SizedBox.shrink();
              
              return IconButton(
                onPressed: () {
                  context.read<TodoBloc>().add(ClearCompletedTodosEvent());
                },
                icon: const Icon(Icons.clear_all),
                tooltip: 'Clear completed todos',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is SavedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Auto-dismiss to idle after showing success message
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                context.read<TodoBloc>().add(ResetToIdleEvent());
              }
            });
          } else if (state is FailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<TodoBloc>().add(LoadTodosEvent());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildStateIndicator(state),
              if (state is DevelopmentState && state.isEditing)
                _buildEditingSection(state)
              else
                _buildAddTodoSection(),
              Expanded(
                child: _buildTodoList(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStateIndicator(TodoState state) {
    Color indicatorColor;
    String stateText;
    IconData stateIcon;

    switch (state.runtimeType) {
      case IdleState:
        indicatorColor = Colors.blue;
        stateText = 'Ready';
        stateIcon = Icons.check_circle_outline;
        break;
      case LoadingState:
        final loadingState = state as LoadingState;
        indicatorColor = Colors.orange;
        stateText = loadingState.operation;
        stateIcon = Icons.hourglass_empty;
        break;
      case DevelopmentState:
        indicatorColor = Colors.purple;
        stateText = 'Editing Mode';
        stateIcon = Icons.edit;
        break;
      case SavedState:
        indicatorColor = Colors.green;
        stateText = 'Saved Successfully';
        stateIcon = Icons.check_circle;
        break;
      case FailedState:
        indicatorColor = Colors.red;
        stateText = 'Error Occurred';
        stateIcon = Icons.error_outline;
        break;
      default:
        indicatorColor = Colors.grey;
        stateText = 'Unknown';
        stateIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: indicatorColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(stateIcon, color: indicatorColor, size: 20),
          const SizedBox(width: 8),
          Text(
            stateText,
            style: TextStyle(
              color: indicatorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (state is LoadingState) ...[
            const Spacer(),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddTodoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Todo Title',
              hintText: 'Enter a todo title...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Enter description...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final title = _titleController.text.trim();
              if (title.isNotEmpty) {
                context.read<TodoBloc>().add(AddTodoEvent(
                  title: title,
                  description: _descriptionController.text.trim(),
                ));
                _titleController.clear();
                _descriptionController.clear();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Todo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingSection(DevelopmentState state) {
    if (state.editingTodo == null) return const SizedBox.shrink();
    
    final todo = state.editingTodo!;
    _editTitleController.text = todo.title;
    _editDescriptionController.text = todo.description;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.purple.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.edit, color: Colors.purple[600]),
              const SizedBox(width: 8),
              Text(
                'Editing Todo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[600],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.read<TodoBloc>().add(CancelEditingEvent());
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _editTitleController,
            decoration: const InputDecoration(
              labelText: 'Todo Title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _editDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TodoBloc>().add(SaveEditedTodoEvent(
                title: _editTitleController.text.trim(),
                description: _editDescriptionController.text.trim(),
              ));
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(TodoState state) {
    final todos = _getTodosFromState(state);
    
    if (todos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No todos yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first todo above!',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _buildTodoItem(todo);
      },
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            context.read<TodoBloc>().add(ToggleTodoEvent(todoId: todo.id));
          },
          activeColor: Colors.green,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: todo.description.isNotEmpty
            ? Text(
                todo.description,
                style: TextStyle(
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  color: todo.isCompleted ? Colors.grey : null,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                context.read<TodoBloc>().add(StartEditingTodoEvent(todo: todo));
              },
              icon: const Icon(Icons.edit),
              tooltip: 'Edit todo',
            ),
            IconButton(
              onPressed: () {
                _showDeleteConfirmation(todo);
              },
              icon: const Icon(Icons.delete),
              tooltip: 'Delete todo',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Todo'),
          content: Text('Are you sure you want to delete \"${todo.title}\"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TodoBloc>().add(DeleteTodoEvent(todoId: todo.id));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  List<Todo> _getTodosFromState(TodoState state) {
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