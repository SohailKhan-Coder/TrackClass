import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/components/show_delete_dialog.dart';
import '../models/attendance_model.dart';
import '../models/students_model.dart';
import '../providers/db_provider.dart';

class StudentDetailsView extends StatefulWidget {
  final Student student;
  const StudentDetailsView({super.key, required this.student});

  @override
  State<StudentDetailsView> createState() => _StudentDetailsViewState();
}

class _StudentDetailsViewState extends State<StudentDetailsView> {
  DateTime? selectedDate;
  DateTimeRange? selectedRange;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedRange = null;
      });
    }
  }

  Future<void> _pickRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: selectedRange,
    );
    if (picked != null) {
      setState(() {
        selectedRange = picked;
        selectedDate = null;
      });
    }
  }

  void _showUpdateDialog(BuildContext context, Attendance att, DBProvider provider) {
    final lessonController = TextEditingController(text: att.lessonQuantity ?? '');
    final sabqiController = TextEditingController(text: att.sabqiQuantity ?? '');
    final manzilController = TextEditingController(text: att.manzilQuantity ?? '');
    final revisionController = TextEditingController(text: att.revisionQuantity ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Attendance"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: lessonController, decoration: const InputDecoration(labelText: "Lesson")),
              TextField(controller: sabqiController, decoration: const InputDecoration(labelText: "Sabqi")),
              TextField(controller: manzilController, decoration: const InputDecoration(labelText: "Manzil")),
              TextField(controller: revisionController, decoration: const InputDecoration(labelText: "Revision")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final updated = att.copyWith(
                lessonQuantity: lessonController.text,
                sabqiQuantity: sabqiController.text,
                manzilQuantity: manzilController.text,
                revisionQuantity: revisionController.text,
              );

              await provider.updateAttendance(updated); // updates DB & provider list
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Attendance updated"), backgroundColor: Colors.green),
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DBProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: Text("${widget.student.name} Details")),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student info
              Container(
                width: double.infinity,
                color: Colors.blue.shade50,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Student: ${widget.student.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (widget.student.sectionId != null)
                      Text("Section: ${widget.student.sectionId}", style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Date filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickDate(context),
                      child: Text(selectedDate == null
                          ? "Pick Date"
                          : DateFormat('dd/MM/yyyy').format(selectedDate!)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _pickRange(context),
                      child: Text(selectedRange == null
                          ? "Pick Range"
                          : "${DateFormat('dd/MM').format(selectedRange!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedRange!.end)}"),
                    ),
                    if (selectedDate != null || selectedRange != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            selectedDate = null;
                            selectedRange = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Attendance list
              Expanded(
                child: FutureBuilder<List<Attendance>>(
                  future: selectedRange != null
                      ? provider.fetchAttendanceForStudentInRange(widget.student.id!, selectedRange!.start, selectedRange!.end)
                      : provider.fetchAttendanceForStudent(widget.student.id!, selectedDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No attendance found"));
                    }

                    final records = snapshot.data!;
                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final att = records[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(
                              DateFormat('EEEE, dd MMM yyyy').format(DateTime.parse(att.date)),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Present: ${att.present == 1 ? "Yes" : "No"}"),
                                if ((att.lessonQuantity ?? "").isNotEmpty)
                                  Text("Lesson: ${att.lessonQuantity}"),
                                if ((att.sabqiQuantity ?? "").isNotEmpty)
                                  Text("Sabqi: ${att.sabqiQuantity}"),
                                if ((att.manzilQuantity ?? "").isNotEmpty)
                                  Text("Manzil: ${att.manzilQuantity}"),
                                if ((att.revisionQuantity ?? "").isNotEmpty)
                                  Text("Revision: ${att.revisionQuantity}"),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.indigo),
                                  onPressed: () => _showUpdateDialog(context, att, provider),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => showDeleteDialog(context, att, provider),
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
            ],
          ),
        );
      },
    );
  }
}
