
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:students_registeration_app/views/attantance_register/attendance_register_view.dart';
import 'package:students_registeration_app/views/attantance_register/tabs/backup_restore_tab.dart';
import 'package:students_registeration_app/views/attantance_register/tabs/students_list_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AttendanceRegisterView(),
    StudentsListView(),
    BackupRestorePage(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Amount",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.backup),
            label: "Backup",
          ),
        ],
      ),
    );
  }
}
