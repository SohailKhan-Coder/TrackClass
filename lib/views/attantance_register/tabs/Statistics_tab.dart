import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/components/custom_card.dart';
import '../../../providers/db_provider.dart';

class StatisticsTab extends StatefulWidget {
  const StatisticsTab({super.key});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  String _selectedView = "Daily";

  @override
  Widget build(BuildContext context) {
    Widget buildCard(String title, List<String> students) {
      return StatCard(
        title: title,
        count: students.length,
        studentNames: students,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Consumer<DBProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                const SizedBox(height: 10,),
                Text(
                  "Statistics & Numbers",
                  style: GoogleFonts.abyssinicaSil(
                      fontSize: 20, fontWeight: FontWeight.bold,color: Colors.indigo),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedView == "Daily"
                          ? "Today's Summary"
                          : _selectedView == "Weekly"
                          ? "Weekly Performance"
                          : _selectedView == "Monthly"
                          ? "Monthly Overview"
                          : "Yearly Overview",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedView,
                      items: const [
                        DropdownMenuItem(value: "Daily", child: Text("Daily")),
                        DropdownMenuItem(
                          value: "Weekly",
                          child: Text("Weekly"),
                        ),
                        DropdownMenuItem(
                          value: "Monthly",
                          child: Text("Monthly"),
                        ),
                        DropdownMenuItem(
                          value: "Yearly",
                          child: Text("Yearly"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _selectedView = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Completed",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                buildCard(
                  "Present",
                  provider.getStudentsByFieldInPeriod("present", _selectedView),
                ),
                buildCard(
                  "Lesson",
                  provider.getStudentsByFieldInPeriod("lesson", _selectedView),
                ),
                buildCard(
                  "Sabqi",
                  provider.getStudentsByFieldInPeriod("sabqi", _selectedView),
                ),
                buildCard(
                  "Manzil",
                  provider.getStudentsByFieldInPeriod("manzil", _selectedView),
                ),
                buildCard(
                  "Revision",
                  provider.getStudentsByFieldInPeriod(
                    "revision",
                    _selectedView,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Missing",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                buildCard(
                  "Lesson",
                  provider.getStudentsMissingFieldInPeriod(
                    "lesson",
                    _selectedView,
                  ),
                ),
                buildCard(
                  "Sabqi",
                  provider.getStudentsMissingFieldInPeriod(
                    "sabqi",
                    _selectedView,
                  ),
                ),
                buildCard(
                  "Manzil",
                  provider.getStudentsMissingFieldInPeriod(
                    "manzil",
                    _selectedView,
                  ),
                ),
                buildCard(
                  "Revision",
                  provider.getStudentsMissingFieldInPeriod(
                    "revision",
                    _selectedView,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
