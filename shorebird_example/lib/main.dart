// This is the main entry point of the Flutter application.
// It displays a production-grade ToDo app using Bloc architecture.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_example/features/todo/bloc/todo_bloc.dart';
import 'package:shorebird_example/features/todo/presentation/todo_component.dart';
import 'package:shorebird_example/features/todo/data/todo_repository.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc(
        repository: TodosRepository(),
      ),
      child: MaterialApp(
        title: 'Production Todo App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
          ),
        ),
        home: const TodoComponent(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
