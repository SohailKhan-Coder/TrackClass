import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/backup_restore_helper.dart';

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
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("Backup saved at: ${file.path}"),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Backup failed: $e"),
        ),
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
        await _backupHelper.restoreFromJson(file, context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Restore failed: $e"),
        ),
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
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Share failed: $e"),
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Text("Backup & Restore",style: GoogleFonts.abrilFatface(fontWeight: FontWeight.w500,fontSize: 20),),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Backup & Restore Data",
                style:  GoogleFonts.abrilFatface(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 30),

              /// Backup
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _backupData,
                icon: const Icon(Icons.backup),
                label: const Text("Backup Data"),
              ),
              const SizedBox(height: 6),
              const Text(
                "Save all your student records into a JSON file for safekeeping.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 25),

              /// Restore
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _restoreData,
                icon: const Icon(Icons.restore),
                label: const Text("Restore Data"),
              ),
              const SizedBox(height: 6),
              const Text(
                "Restore data from a previously saved backup file.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 25),

              /// Share
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _shareBackup,
                icon: const Icon(Icons.share),
                label: const Text("Share Backup"),
              ),
              const SizedBox(height: 6),
              const Text(
                "Easily share your backup file via email, WhatsApp, or other apps.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
