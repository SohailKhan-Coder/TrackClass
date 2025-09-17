import 'package:flutter/material.dart';
import '../../models/attendance_model.dart';
import '../../providers/db_provider.dart';

Future<void> showDeleteDialog(
    BuildContext context, Attendance att, DBProvider provider) async {
  bool deleteLesson = false;
  bool deleteSabqi = false;
  bool deleteManzil = false;
  bool deleteRevision = false;
  bool deleteAll = false;

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text("Delete Attendance Fields"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text("Delete Lesson"),
                value: deleteLesson,
                onChanged: (val) => setState(() => deleteLesson = val ?? false),
              ),
              CheckboxListTile(
                title: const Text("Delete Sabqi"),
                value: deleteSabqi,
                onChanged: (val) => setState(() => deleteSabqi = val ?? false),
              ),
              CheckboxListTile(
                title: const Text("Delete Manzil"),
                value: deleteManzil,
                onChanged: (val) => setState(() => deleteManzil = val ?? false),
              ),
              CheckboxListTile(
                title: const Text("Delete Revision"),
                value: deleteRevision,
                onChanged: (val) => setState(() => deleteRevision = val ?? false),
              ),
              const Divider(),
              CheckboxListTile(
                title: const Text("Delete All Fields"),
                value: deleteAll,
                onChanged: (val) => setState(() => deleteAll = val ?? false),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool deleteRecord = !deleteLesson &&
                  !deleteSabqi &&
                  !deleteManzil &&
                  !deleteRevision &&
                  !deleteAll;

              await provider.deleteAttendanceFieldsOrRecord(
                att,
                deleteLesson: deleteLesson,
                deleteSabqi: deleteSabqi,
                deleteManzil: deleteManzil,
                deleteRevision: deleteRevision,
                deleteAllFields: deleteAll,
                deleteRecord: deleteRecord,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Attendance deleted successfully"),
                ),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    ),
  );
}

