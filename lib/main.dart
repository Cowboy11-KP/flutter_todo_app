import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/local/hive_service.dart';
import 'package:frontend/data/remote/firebase_service.dart';
import 'package:frontend/repository/todo_repository.dart';
import 'package:frontend/service/firebase_options.dart';
import 'package:frontend/viewmodels/auth_cubit.dart';
import 'package:frontend/viewmodels/auth_service.dart';
import 'package:frontend/viewmodels/todo_cubit.dart';
import 'package:frontend/views/home/home_screen.dart';
import 'package:frontend/views/onboarding/onboarding_screen.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 Khởi tạo Hive
  await Hive.initFlutter();
  await LocalTodoService.initHive(); // phương thức init() trong Hive service của bạn

  // 🔹 Tạo các service cần thiết
  final localService = LocalTodoService();
  final remoteService = FirebaseTodoService();
  final authService = AuthService();

  // 🔹 Tạo repository dùng chung
  final todoRepository = TodoRepository(
    local: localService,
    remote: remoteService,
    authService: authService,
  );

  // 🔹 Chạy app với BlocProvider
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UpTodo App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen()
    );
  }
}
