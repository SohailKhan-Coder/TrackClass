import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:students_registeration_app/views/student_details%20view.dart';
import '../../models/students_model.dart';
import '../../providers/db_provider.dart';

class StudentAmountView extends StatelessWidget {
  const StudentAmountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Students List",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(thickness: 1),
            // Expanded ListView inside Column
            Expanded(
              child: Consumer<DBProvider>(
                builder: (context, provider, _) {
                  final students = provider.students;

                  if (students.isEmpty) {
                    return const Center(
                      child: Text("No students available"),
                    );
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final Student student = students[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(student.name),
                          subtitle: Text("Phone: ${student.phone ?? 'N/A'}"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StudentDetailsView(student: student),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
