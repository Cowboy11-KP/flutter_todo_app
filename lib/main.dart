import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/local/hive_config.dart';
import 'package:frontend/data/local/hive_service.dart';
// import 'package:frontend/data/remote/firebase_service.dart';
import 'package:frontend/repository/task/task_repository.dart';
import 'package:frontend/service/firebase_options.dart';
import 'package:frontend/service/notification_service.dart';
import 'package:frontend/viewmodels/auth_cubit.dart';
import 'package:frontend/data/remote/auth_service.dart';
import 'package:frontend/viewmodels/task_cubit.dart';
import 'package:frontend/views/onboarding/onboarding_screen.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await HiveConfig.init();

  await NotificationService.init();
  final localService = LocalTaskService();
  //final remoteService = FirebaseTodoService();
  final authService = AuthService();

  final todoRepository = TaskRepository(
    local: localService,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authService)),
        BlocProvider(create: (_) => TaskCubit(todoRepository)..loadTodos()),
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
