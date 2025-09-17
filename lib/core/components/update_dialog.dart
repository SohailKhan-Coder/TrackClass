import 'package:flutter/material.dart';
import '../../models/attendance_model.dart';
import '../../providers/db_provider.dart';


Future<void> showUpdateAttendanceDialog(
    BuildContext context, Attendance att, DBProvider provider) async {
  final lessonController = TextEditingController(text: att.lessonQuantity ?? '');
  final sabqiController = TextEditingController(text: att.sabqiQuantity ?? '');
  final manzilController = TextEditingController(text: att.manzilQuantity ?? '');
  final revisionController = TextEditingController(text: att.revisionQuantity ?? '');

  await showDialog(
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final updated = att.copyWith(
              lessonQuantity: lessonController.text,
              sabqiQuantity: sabqiController.text,
              manzilQuantity: manzilController.text,
              revisionQuantity: revisionController.text,
            );

            await provider.updateAttendance(updated); // make sure method exists in DBProvider
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Attendance updated")),
            );
          },
          child: const Text("Update"),
        ),
      ],
    ),
  );
}
