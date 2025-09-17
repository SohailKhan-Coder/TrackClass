import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:students_registeration_app/core/constants/app_theme.dart';
import 'providers/db_provider.dart';
import 'views/attantance_register/attendance_register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => DBProvider()..initializeSections(),
      child: const StudentsDetailApp(),
    ),
  );
}

class StudentsDetailApp extends StatelessWidget {
  const StudentsDetailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      title: 'Attendance Register',
      home: const AttendanceRegisterView(),
    );
  }
}
