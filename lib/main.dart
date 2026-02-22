import 'package:flutter/material.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/repository/auth/auth_repository.dart';

import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/service/firebase_auth_service.dart';
import 'package:frontend/service/notification_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mvvm/viewmodels/user/user_cubit.dart';
import 'package:frontend/mvvm/views/auth/login_screen.dart';
import 'package:frontend/mvvm/views/home/home_screen.dart';
import 'package:frontend/mvvm/views/onboarding/onboarding_screen.dart';
import 'package:frontend/mvvm/views/onboarding/start_screen.dart';
import 'package:frontend/mvvm/views/splash_screen.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/datasources/local/hive_config.dart';
import 'package:frontend/datasources/local/hive_service.dart';

import 'package:frontend/repository/task/task_repository.dart';
import 'package:frontend/mvvm/viewmodels/auth/auth_cubit.dart';
import 'package:frontend/mvvm/viewmodels/task/task_cubit.dart';
import 'package:frontend/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  

  await Hive.initFlutter();
  await HiveConfig.init();

  await NotificationService.init();

  final localService = LocalTaskService();
  final authService = AuthService();
  
  final userRepository = UserRepository();
  
  final todoRepository = TaskRepository(
    local: localService,
  );
  final authRepository = AuthRepository(
    authService: authService,
    local: localService,
    taskRepository: todoRepository, 
    userRepository: userRepository
  );


  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authRepository)),
        BlocProvider(create: (_) => TaskCubit(todoRepository)..loadTodos()),
        BlocProvider(create: (_) => UserCubit(userRepository)),
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
      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/start': (context) => const StartScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}