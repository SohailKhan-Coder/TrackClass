import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../services/backup_restore_helper.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final BackupHelper _backupHelper = BackupHelper();
  bool _isLoading = false;

  Future<void> _backupData() async {
    setState(() => _isLoading = true);
    try {
      final file = await _backupHelper.backupToJson();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Backup saved at: ${file.path}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Backup failed: $e")),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _restoreData() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _backupHelper.restoreFromJson(file, context); // ✅ pass context
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Restore failed: $e")),
      );
    }
    setState(() => _isLoading = false);
  }


  Future<void> _shareBackup() async {
    setState(() => _isLoading = true);
    try {
      final file = await _backupHelper.backupToJson();
      await _backupHelper.shareBackup(file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Share failed: $e")),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(25)
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Backup & Restore Data",style: TextStyle(fontSize: 20,color: Colors.indigo,fontWeight: FontWeight.bold),),
              SizedBox(height: 50,),

              ElevatedButton.icon(
                onPressed: _backupData,
                icon: const Icon(Icons.backup),
                label: const Text("Backup Data"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _restoreData,
                icon: const Icon(Icons.restore),
                label: const Text("Restore Data"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _shareBackup,
                icon: const Icon(Icons.share),
                label: const Text("Share Backup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
