import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/students_model.dart';
import '../../providers/db_provider.dart';
import 'students_amount_detail_view.dart';
import '../bottom_navigator_bar_view.dart';

class StudentsListView extends StatefulWidget {
  const StudentsListView({super.key});

  @override
  State<StudentsListView> createState() => _StudentsListViewState();
}

class _StudentsListViewState extends State<StudentsListView> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AppScaffold()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          "Students Amount",
          style: GoogleFonts.abrilFatface(
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search students",
                prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                filled: true,
                fillColor: Colors.indigo.shade50,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<DBProvider>(
                builder: (context, provider, _) {
                  final students = provider.students
                      .where((student) =>
                  student.name.toLowerCase().contains(_searchQuery) ||
                      (student.phone?.toLowerCase() ?? "")
                          .contains(_searchQuery))
                      .toList();

                  if (students.isEmpty) {
                    return const Center(
                      child: Text(
                        "No students found",
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.indigo.shade100,
                            child:
                            const Icon(Icons.school, color: Colors.indigo),
                          ),
                          title: Text(
                            student.name,
                            style: GoogleFonts.abyssinicaSil(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "Phone: ${student.phone ?? 'N/A'}",
                            style: const TextStyle(color: Colors.indigo),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              final scaffoldState =
                              context.findAncestorStateOfType<
                                  AppScaffoldState>();
                              scaffoldState?.openDetail(
                                StudentDetailsView(student: student),
                              );
                            },
                          ),
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
