import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:students_registeration_app/providers/db_provider.dart';
import 'package:students_registeration_app/views/attantance_register/tabs/StatisticsTab.dart';
import 'package:students_registeration_app/views/attantance_register/tabs/StudentManagementTab.dart';
import 'package:students_registeration_app/views/attantance_register/tabs/backup_restore_tab.dart';
import 'package:students_registeration_app/views/attantance_register/tabs/attandance_tab.dart';
import 'package:students_registeration_app/views/attantance_register/tabs/open_slide_menu.dart';
import 'package:students_registeration_app/views/attantance_register/tabs/student_amount_tab.dart';
import '../../models/section_model.dart';

class AttendanceRegisterView extends StatefulWidget {
  const AttendanceRegisterView({super.key});

  @override
  State<AttendanceRegisterView> createState() => _AttendanceRegisterViewState();
}

class _AttendanceRegisterViewState extends State<AttendanceRegisterView> {
  String selectedTab = "Attendance";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DBProvider>(context, listen: false);

      if (provider.currentSectionId == null && provider.sections.isNotEmpty) {
        provider.setCurrentSection(provider.sections.first.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () => SideMenu.show(context), icon: const Icon(Icons.menu))
        ],
        title: const Text("Attendance & Lesson Registration"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Dropdown for Sections
            Consumer<DBProvider>(
              builder: (context, provider, child) {
                final sections = provider.sections;
                final currentId = provider.currentSectionId;

                if (sections.isEmpty) {
                  return const Text("No sections available");
                }

                final selected = sections.firstWhere(
                      (s) => s.id == currentId,
                  orElse: () => sections.first,
                );

                return DropdownButtonFormField<Section>(
                  decoration: InputDecoration(
                    labelText: "Select Section",
                    prefixIcon: const Icon(Icons.class_, color: Colors.indigo),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.indigo, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.indigo, width: 2),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  isExpanded: true,
                  value: selected,
                  items: sections.map(
                        (section) {
                      return DropdownMenuItem<Section>(
                        value: section,
                        child: Text(
                          section.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setCurrentSection(value.id!);
                    }
                  },
                  validator: (value) =>
                  value == null ? "Please select a section" : null,
                );

              },
            ),

            const SizedBox(height: 12),

            /// Choice Chips (Tabs)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChoiceChip("Attendance"),
                  const SizedBox(width: 10),
                  _buildChoiceChip("Statistics"),
                  const SizedBox(width: 10),
                  _buildChoiceChip("Student Management"),
                  const SizedBox(width: 10),
                  _buildChoiceChip("Amount Details"),
                  const SizedBox(width: 10),
                  _buildChoiceChip("App Settings"), // ⚡ new tab
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Tab content
            Expanded(child: getTabContent()),
          ],
        ),
      ),
    );
  }

  /// ChoiceChip builder
  Widget _buildChoiceChip(String label) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: selectedTab == label ? Colors.white : Colors.indigo,
        ),
      ),
      selected: selectedTab == label,
      selectedColor: Colors.indigo,
      backgroundColor: Colors.white,
      shape: const StadiumBorder(
        side: BorderSide(color: Colors.indigo),
      ),
      checkmarkColor: Colors.white,
      onSelected: (_) {
        setState(() {
          selectedTab = label;
        });
      },
    );
  }

  /// Returns the correct tab widget
  Widget getTabContent() {
    switch (selectedTab) {
      case "Attendance":
        return const AttendanceTab();
      case "Statistics":
        return const StatisticsTab();
      case "Student Management":
        return const StudentManagementTab();
      case "Amount Details":
        return StudentAmountView();
      case "App Settings":
        return const BackupRestorePage();// ⚡ new tab content
      default:
        return const SizedBox();
    }
  }
}
