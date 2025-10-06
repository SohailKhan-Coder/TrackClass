import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../providers/db_provider.dart';
import '../services/db_helper.dart';

class BackupHelper {
  final DBHelper _dbHelper = DBHelper();

  Future<File> backupToJson() async {
    final data = await _dbHelper.exportToJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final dir = Directory('/storage/emulated/0/Download/MyAppBackup');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final file = File('${dir.path}/backup_$timestamp.json');
    await file.writeAsString(jsonString);

    return file;
  }

  Future<void> restoreFromJson(File file, BuildContext context) async {
    final db = await _dbHelper.database;
    final content = await file.readAsString();
    final data = jsonDecode(content);

    await db.delete('attendance');
    await db.delete('students');
    await db.delete('sections');

    for (var sec in data['sections']) {
      await db.insert('sections', Map<String, dynamic>.from(sec));
    }
    for (var stu in data['students']) {
      await db.insert('students', Map<String, dynamic>.from(stu));
    }
    for (var att in data['attendance']) {
      await db.insert('attendance', Map<String, dynamic>.from(att));
    }

    final provider = Provider.of<DBProvider>(context, listen: false);
    await provider.reloadAllData();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Data restored successfully")));
  }

  Future<void> shareBackup(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'MyApp Backup File');
  }
}
