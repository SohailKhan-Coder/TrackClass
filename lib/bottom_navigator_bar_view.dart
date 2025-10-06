import 'package:flutter/material.dart';
import 'package:students_registeration_app/views/attantance_register/attendance_register_view.dart';
import 'package:students_registeration_app/views/backup_restore_view.dart';
import 'package:students_registeration_app/views/students_amount_view.dart';



class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  AppScaffoldState createState() => AppScaffoldState();
}

class AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  Widget? _detailPage;

  final List<Widget> _pages = const [
    AttendanceRegisterView(),
    StudentsListView(),
    BackupRestorePage(),
  ];

  final List<String> _titles = [
    "Attendance",
    "Students",
    "Backup & Restore",
  ];

  void openDetail(Widget page) {
    setState(() {
      _detailPage = page;
    });
  }

  /// Close the detail page
  void closeDetail() {
    setState(() {
      _detailPage = null;
    });
  }

  /// Navigate to a main tab
  void setTab(int index) {
    setState(() {
      _currentIndex = index;
      _detailPage = null; // Close any detail page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _detailPage ?? _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setTab(index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.checklist), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Amounts"),
          BottomNavigationBarItem(icon: Icon(Icons.backup), label: "Backup"),
        ],
      ),
    );
  }
}
