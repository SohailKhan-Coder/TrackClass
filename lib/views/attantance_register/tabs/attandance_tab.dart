import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/components/lesson_dialog.dart';
import '../../../models/attendance_model.dart';
import '../../../providers/db_provider.dart';
import '../../../core/components/custom_text_field.dart';

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({super.key});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  final TextEditingController _studentController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      // Update provider with new date
      final provider = Provider.of<DBProvider>(context, listen: false);
      provider.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DBProvider>(
      builder: (context, provider, _) {
        final filteredStudents = provider.students
            .where((s) => s.name
            .toLowerCase()
            .contains(_studentController.text.toLowerCase()))
            .toList();

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(25),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                // Date Picker
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _pickDate(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blue[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(provider.selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DateFormat('EEEE, d MMMM yyyy')
                              .format(provider.selectedDate),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Field
                CustomTextField(
                  controller: _studentController,
                  hintText: "Search Student",
                  labelText: "Search",
                  prefixIcon: Icons.search,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),

                // Attendance Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Present")),
                      DataColumn(label: Text("Lesson")),
                      DataColumn(label: Text("Sabqi")),
                      DataColumn(label: Text("Manzil")),
                      DataColumn(label: Text("Revision")),
                    ],
                    rows: filteredStudents.map((student) {
                      final Attendance attendance = provider.dailyAttendance.firstWhere(
                            (a) => a.studentId == student.id,
                        orElse: () => Attendance(studentId: student.id!, date: provider.selectedDateString),
                      );


                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (attendance != null && attendance.present == 1) {
                                return Colors.green.withOpacity(0.2);
                              }
                              return null;
                            }),
                        cells: [
                          DataCell(Text(student.name)),

                          // Present Checkbox
                          DataCell(Checkbox(
                            value: attendance?.present == 1,
                            onChanged: (val) {
                              provider.togglePresent(
                                  student.id!, val ?? false);
                            },
                          )),

                          // Lesson Checkbox
                          DataCell(Row(
                            children: [

                              Checkbox(
                                value: attendance?.lesson == 1,
                                onChanged: (attendance?.present == 1)
                                    ? (val) {
                                  provider.toggleLesson(
                                      student.id!, val ?? false);
                                }
                                    : null,
                              ),
                              TextButton(
                                child: Text("Amount"),
                                onPressed: () {
                                  showQuantityDialog(
                                    context,
                                    student.id!,
                                    student.name,
                                    "Lesson",
                                  );
                                },
                              ),
                            ],
                          )),

                          // Sabqi Checkbox
                          DataCell(Row(

                            children: [
                              Checkbox(
                                value: attendance?.sabqi == 1,
                                onChanged: (attendance?.present == 1)
                                    ? (val) {
                                  provider.toggleSabqi(
                                      student.id!, val ?? false);
                                }
                                    : null,
                              ),
                              TextButton(
                                child: Text("Amount"),
                                onPressed: () {
                                  showQuantityDialog(
                                    context,
                                    student.id!,
                                    student.name,
                                    "Sabqi",
                                  );
                                },
                              ),
                            ],
                          )),

                          // Manzil Checkbox
                          DataCell(Row(
                            children: [
                              Checkbox(
                                value: attendance?.manzil == 1,
                                onChanged: (attendance?.present == 1)
                                    ? (val) {
                                  provider.toggleManzil(
                                      student.id!, val ?? false);
                                }
                                    : null,
                              ),
                              TextButton(
                                child: Text("Amount"),
                                onPressed: () {
                                  showQuantityDialog(
                                    context,
                                    student.id!,
                                    student.name,
                                    "Manzil",
                                  );
                                },
                              ),
                            ],
                          )),

                          // Revision Checkbox
                          DataCell(Row(
                            children: [
                              Checkbox(
                                value: attendance?.revision == 1,
                                onChanged: (attendance?.present == 1)
                                    ? (val) {
                                  provider.toggleRevision(
                                      student.id!, val ?? false);
                                }
                                    : null,
                              ),
                              TextButton(
                                child: Text("Amount"),
                                onPressed: () {
                                  showQuantityDialog(
                                    context,
                                    student.id!,
                                    student.name,
                                    "Revision",
                                  );
                                },
                              ),
                              IconButton(
                                onPressed: () async {
                                  if (student.phone != null && student.phone!.isNotEmpty) {
                                    // WhatsApp URL
                                    final whatsappUrl = "https://wa.me/${student.phone}?text=Hello!";

                                    final uri = Uri.parse(whatsappUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Could not open WhatsApp')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Phone number not available')),
                                    );
                                  }
                                },
                                icon: const FaIcon(FontAwesomeIcons.whatsapp,color: Colors.green,),
                              )
                            ],
                          )),

                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
