import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:students_registeration_app/models/students_model.dart';
import 'package:students_registeration_app/providers/db_provider.dart';
import '../../../core/components/custom_text_field.dart';

class StudentManagementTab extends StatefulWidget {
  const StudentManagementTab({super.key});

  @override
  State<StudentManagementTab> createState() => _StudentManagementTabState();
}

class _StudentManagementTabState extends State<StudentManagementTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DBProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(25),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            /// Add Student Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const Text(
                      "Students Management",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _nameController,
                      hintText: "Student Name",
                      labelText: "Name",
                      prefixIcon: Icons.person,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _phoneController,
                      hintText: "Phone Number",
                      labelText: "Phone",
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),

                    /// Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.indigo),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: () async {
                          if (provider.currentSectionId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text("Please select a section first")),
                            );
                            return;
                          }

                          await provider.addStudent(
                              _nameController.text, _phoneController.text);

                          _nameController.clear();
                          _phoneController.clear();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                backgroundColor: Colors.green,
                                content:
                                Text("Student registered successfully")),
                          );
                        },
                        child: const Text("Register Student"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// Students List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text(
                      "Present Students List",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _searchController,
                      hintText: 'Search Student Name',
                      labelText: 'Search',
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        setState(() {}); // trigger search filter
                      },
                    ),
                    const SizedBox(height: 10),

                    Consumer<DBProvider>(
                      builder: (context, provider, child) {
                        List<Student> students = provider.students;

                        // Apply search filter
                        if (_searchController.text.isNotEmpty) {
                          students = students
                              .where((s) => s.name
                              .toLowerCase()
                              .contains(_searchController.text
                              .toLowerCase()))
                              .toList();
                        }

                        if (students.isEmpty) {
                          return const Center(
                              child: Text("No students in this section"));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.person,
                                    color: Colors.indigo),
                                title: Text(student.name),
                                subtitle: Text(student.phone ?? ""),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    /// Edit button
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        _showEditDialog(context, student);
                                      },
                                    ),

                                    /// Delete button
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        provider.deleteStudent(student.id!);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Show edit dialog
  void _showEditDialog(BuildContext context, Student student) {
    final nameController = TextEditingController(text: student.name);
    final phoneController = TextEditingController(text: student.phone ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: nameController,
              labelText: "Name",
              prefixIcon: Icons.person, hintText: 'Enter your name',
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: phoneController,
              labelText: "Phone",
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              hintText: 'Enter your phone',
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.indigo),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
            ),
            child: const Text("Save"),
            onPressed: () async {
              final provider =
              Provider.of<DBProvider>(context, listen: false);

              final updatedStudent = Student(
                id: student.id,
                name: nameController.text,
                phone: phoneController.text,
                sectionId: student.sectionId,
              );

              await provider.updateStudent(updatedStudent);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text("Student updated successfully")),
              );
            },
          ),
        ],
      ),
    );
  }
}
