import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/local/hive_service.dart';
// import 'package:frontend/data/remote/firebase_service.dart';
import 'package:frontend/repository/todo_repository.dart';
import 'package:frontend/service/firebase_options.dart';
import 'package:frontend/viewmodels/auth_cubit.dart';
import 'package:frontend/data/remote/auth_service.dart';
import 'package:frontend/viewmodels/todo_cubit.dart';
import 'package:frontend/views/onboarding/onboarding_screen.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await LocalTodoService.initHive();

  final localService = LocalTodoService();
  //final remoteService = FirebaseTodoService();
  final authService = AuthService();

  final todoRepository = TodoRepository(
    local: localService,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authService)),
        BlocProvider(create: (_) => TodoCubit(todoRepository)..loadTodos()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UpTodo App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: OnboardingScreen()
    );
  }
}
