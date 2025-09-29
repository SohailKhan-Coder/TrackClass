import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:students_registeration_app/bottom_navigator_bar_view.dart';

import '../../../../models/students_model.dart';
import '../../../../providers/db_provider.dart';
import '../../students_details_view.dart';

class StudentsListView extends StatelessWidget {
  const StudentsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // light background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainView()));
          },
        ),
        title: Text("Students",style: GoogleFonts.aclonica(fontWeight: FontWeight.bold,fontSize: 26)),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<DBProvider>(
          builder: (context, provider, _) {
            final students = provider.students;

            if (students.isEmpty) {
              return const Center(
                child: Text(
                  "No students available",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.separated(
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final Student student = students[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.indigo.shade100,
                      child: const Icon(Icons.school, color: Colors.indigo),
                    ),
                    title: Text(
                      student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text("Phone: ${student.phone ?? 'N/A'}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios,
                              size: 18, color: Colors.grey),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StudentDetailsView(student: student),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
