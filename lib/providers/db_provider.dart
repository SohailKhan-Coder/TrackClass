import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/students_model.dart';
import '../models/section_model.dart';
import '../models/attendance_model.dart';
import '../services/db_helper.dart';

class DBProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  DBHelper get dbHelper => _dbHelper;


  List<Section> _sections = [];
  List<Student> _students = [];
  List<Attendance> _dailyAttendance = [];
  List<Attendance> _allAttendance = [];
  int? _currentSectionId;
  DateTime _selectedDate = DateTime.now();


  List<Section> get sections => _sections;
  List<Student> get students => _students;
  int? get currentSectionId => _currentSectionId;
  List<Attendance> get dailyAttendance => _dailyAttendance;
  List<Attendance> get allAttendance => _allAttendance;
  DateTime get selectedDate => _selectedDate;
  String get selectedDateString =>
      DateFormat('yyyy-MM-dd').format(_selectedDate);



  Future<void> initializeSections() async {
    _sections = await _dbHelper.getSections();
    if (_sections.isEmpty) {
      await _dbHelper.insertSection(Section(name: 'Section 1'));
      await _dbHelper.insertSection(Section(name: 'Section 2'));
      await _dbHelper.insertSection(Section(name: 'Section 3'));
      _sections = await _dbHelper.getSections();
    }
    await _loadCurrentSectionId();
    if (_currentSectionId == null && _sections.isNotEmpty) {
      _currentSectionId = _sections.first.id;
    }
    await loadStudentsForCurrentSection();
    await loadAttendanceForDate();
    await loadAllAttendance();
    notifyListeners();
  }

  Future<void> setCurrentSection(int id) async {
    _currentSectionId = id;
    await _saveCurrentSectionId();
    await loadStudentsForCurrentSection();
    await loadAttendanceForDate();
    await loadAllAttendance();
    notifyListeners();
  }

  Future<void> loadStudentsForCurrentSection() async {
    if (_currentSectionId == null) {
      _students = [];
    } else {
      _students = await _dbHelper.getStudents(_currentSectionId!);
    }
    notifyListeners();
  }

  Future<void> addStudent(String name, String? phone) async {
    if (_currentSectionId == null) return;
    final newStudent = Student(
      name: name,
      phone: phone,
      sectionId: _currentSectionId!,
    );
    await _dbHelper.insertStudent(newStudent);
    await loadStudentsForCurrentSection();
    await loadAttendanceForDate();
    await loadAllAttendance();
    notifyListeners();
  }

  Future<void> deleteStudent(int studentId) async {
    await _dbHelper.deleteStudent(studentId);
    await loadStudentsForCurrentSection();
    await loadAttendanceForDate();
    await loadAllAttendance();
    notifyListeners();
  }

  Future<void> updateStudent(Student student) async {
    if (student.id == null) return;
    await _dbHelper.updateStudent(student);
    await loadStudentsForCurrentSection();
    await loadAttendanceForDate();
    await loadAllAttendance();
    notifyListeners();
  }


  //Date Managements

  Future<void> setDate(DateTime date) async {
    _selectedDate = date;
    await loadAttendanceForDate();
    notifyListeners();
  }


  // Attendance managements

  Future<void> loadAllAttendance() async {
    if (_currentSectionId == null) return;
    _allAttendance = await _dbHelper.getAttendanceBySection(_currentSectionId!);
    notifyListeners();
  }

  Future<void> loadAttendanceForDate({bool createMissingRecords = true}) async {
    if (_currentSectionId == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _dailyAttendance =
    await _dbHelper.getAttendanceByDate(dateStr, _currentSectionId!);

    if (createMissingRecords) {
      for (var student in _students) {
        if (!_dailyAttendance.any((a) => a.studentId == student.id)) {
          final newRecord = Attendance(
            studentId: student.id!,
            date: dateStr,
            present: 0,
            lesson: 0,
            sabqi: 0,
            manzil: 0,
            revision: 0,
          );
          final newId = await _dbHelper.insertAttendance(newRecord);
          _dailyAttendance.add(newRecord.copyWith(id: newId));
        }
      }
    }

    await loadAllAttendance();
    notifyListeners();
  }

  Future<void> _toggleField(int studentId, String field, bool value) async {
    final index = _dailyAttendance.indexWhere((a) => a.studentId == studentId);
    if (index == -1) return;

    Attendance current = _dailyAttendance[index];

    Attendance updated = current.copyWith(
      present: field == 'present' ? (value ? 1 : 0) : current.present,
      lesson: field == 'lesson' ? (value ? 1 : 0) : current.lesson,
      sabqi: field == 'sabqi' ? (value ? 1 : 0) : current.sabqi,
      manzil: field == 'manzil' ? (value ? 1 : 0) : current.manzil,
      revision: field == 'revision' ? (value ? 1 : 0) : current.revision,
    );

    _dailyAttendance[index] = updated;
    await _dbHelper.updateAttendance(updated);
    await loadAllAttendance();
    notifyListeners();
  }

  void togglePresent(int studentId, bool value) =>
      _toggleField(studentId, 'present', value);
  void toggleLesson(int studentId, bool value) =>
      _toggleField(studentId, 'lesson', value);
  void toggleSabqi(int studentId, bool value) =>
      _toggleField(studentId, 'sabqi', value);
  void toggleManzil(int studentId, bool value) =>
      _toggleField(studentId, 'manzil', value);
  void toggleRevision(int studentId, bool value) =>
      _toggleField(studentId, 'revision', value);

  List<String> getStudentsByFieldInPeriod(String field, String period) {
    DateTime now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (period) {
      case "Daily":
        start = now;
        break;
      case "Weekly":
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case "Monthly":
        start = DateTime(now.year, now.month, 1);
        break;
      case "Yearly":
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = now;
    }

    final recordsInRange = _allAttendance.where((a) {
      DateTime recordDate = DateTime.parse(a.date);
      return recordDate.isAfter(start.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    List<String> result = [];
    for (var student in _students) {
      final studentRecords =
      recordsInRange.where((a) => a.studentId == student.id).toList();
      bool hasDone = studentRecords.any((a) {
        switch (field) {
          case "present":
            return a.present == 1;
          case "lesson":
            return a.lesson == 1;
          case "sabqi":
            return a.sabqi == 1;
          case "manzil":
            return a.manzil == 1;
          case "revision":
            return a.revision == 1;
          default:
            return false;
        }
      });
      if (hasDone) result.add(student.name);
    }

    return result;
  }

  List<String> getStudentsMissingFieldInPeriod(String field, String period) {
    DateTime now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (period) {
      case "Daily":
        start = now;
        break;
      case "Weekly":
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case "Monthly":
        start = DateTime(now.year, now.month, 1);
        break;
      case "Yearly":
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = now;
    }

    final recordsInRange = _allAttendance.where((a) {
      DateTime recordDate = DateTime.parse(a.date);
      return recordDate.isAfter(start.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    List<String> missing = [];
    for (var student in _students) {
      final studentRecords =
      recordsInRange.where((a) => a.studentId == student.id).toList();
      bool missedAll = studentRecords.isEmpty ||
          studentRecords.every((a) {
            switch (field) {
              case "lesson":
                return a.lesson != 1;
              case "sabqi":
                return a.sabqi != 1;
              case "manzil":
                return a.manzil != 1;
              case "revision":
                return a.revision != 1;
              default:
                return true;
            }
          });
      if (missedAll) missing.add(student.name);
    }

    return missing;
  }
  // Lesson Details

  Future<bool> saveLessonDetails(
      int studentId, String details, String columnName) async {
    try {
      final db = await _dbHelper.database;
      final date = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final result = await db.query(
        'attendance',
        where: 'student_id = ? AND date = ?',
        whereArgs: [studentId, date],
      );

      Map<String, dynamic> values = {};
      switch (columnName) {
        case "Lesson":
          values['lesson'] = 1;
          values['lessonQuantity'] = details;
          break;
        case "Sabqi":
          values['sabqi'] = 1;
          values['sabqiQuantity'] = details;
          break;
        case "Manzil":
          values['manzil'] = 1;
          values['manzilQuantity'] = details;
          break;
        case "Revision":
          values['revision'] = 1;
          values['revisionQuantity'] = details;
          break;
      }

      if (result.isEmpty) {
        values['student_id'] = studentId;
        values['date'] = date;
        await db.insert('attendance', values);
      } else {
        final id = result.first['id'] as int;
        await db.update('attendance', values, where: 'id = ?', whereArgs: [id]);
      }

      await loadAllAttendance();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error saving lesson details: $e");
      return false;
    }
  }

  Future<List<Attendance>> fetchAttendanceForStudent(int studentId,
      [DateTime? date]) async {
    final String? dateStr =
    date == null ? null : DateFormat('yyyy-MM-dd').format(date);
    return await _dbHelper.getAttendanceByStudentAndDate(studentId,
        date: dateStr);
  }

  Future<List<Attendance>> fetchAttendanceForStudentInRange(
      int studentId, DateTime start, DateTime end) async {
    final startStr = DateFormat('yyyy-MM-dd').format(start);
    final endStr = DateFormat('yyyy-MM-dd').format(end);
    return await _dbHelper.getAttendanceByStudentAndRange(studentId, startStr, endStr);
  }

  Future<void> deleteAttendance(int id) async {
    await _dbHelper.deleteAttendance(id);
    _dailyAttendance.removeWhere((att) => att.id == id);
    await loadAllAttendance();
    notifyListeners();
  }

  Future<void> updateAttendance(Attendance att) async {
    await _dbHelper.updateAttendance(att);
    await loadAllAttendance();
    notifyListeners();
  }

  Future<void> deleteAttendanceFieldsOrRecord(
      Attendance att, {
        bool deleteLesson = false,
        bool deleteSabqi = false,
        bool deleteManzil = false,
        bool deleteRevision = false,
        bool deleteAllFields = false,
        bool deleteRecord = false,
      }) async {
    final db = await _dbHelper.database;

    if (deleteRecord) {
      await _dbHelper.deleteAttendance(att.id!);
      _dailyAttendance.removeWhere((a) => a.id == att.id);
    } else {
      Map<String, dynamic> values = {};
      if (deleteAllFields || deleteLesson) {
        values['lesson'] = 0;
        values['lessonQuantity'] = '';
      }
      if (deleteAllFields || deleteSabqi) {
        values['sabqi'] = 0;
        values['sabqiQuantity'] = '';
      }
      if (deleteAllFields || deleteManzil) {
        values['manzil'] = 0;
        values['manzilQuantity'] = '';
      }
      if (deleteAllFields || deleteRevision) {
        values['revision'] = 0;
        values['revisionQuantity'] = '';
      }

      if (values.isNotEmpty) {
        await db.update('attendance', values,
            where: 'id = ?', whereArgs: [att.id]);
        final index = _dailyAttendance.indexWhere((a) => a.id == att.id);
        if (index != -1) {
          _dailyAttendance[index] = _dailyAttendance[index].copyWith(
            lesson: values['lesson'] ?? att.lesson,
            lessonQuantity: values['lessonQuantity'] ?? att.lessonQuantity,
            sabqi: values['sabqi'] ?? att.sabqi,
            sabqiQuantity: values['sabqiQuantity'] ?? att.sabqiQuantity,
            manzil: values['manzil'] ?? att.manzil,
            manzilQuantity: values['manzilQuantity'] ?? att.manzilQuantity,
            revision: values['revision'] ?? att.revision,
            revisionQuantity:
            values['revisionQuantity'] ?? att.revisionQuantity,
          );
        }
      }
    }

    await loadAllAttendance();
    notifyListeners();
  }




  Future<void> _saveCurrentSectionId() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentSectionId != null) {
      await prefs.setInt('currentSectionId', _currentSectionId!);
    }
  }

  Future<void> _loadCurrentSectionId() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSectionId = prefs.getInt('currentSectionId');
  }

  Future<void> loadSections() async {
    _sections = await _dbHelper.getSections();

    final hasCurrent = _currentSectionId != null && _sections.any((s) => s.id == _currentSectionId);
    if (!hasCurrent && _sections.isNotEmpty) {
      _currentSectionId = _sections.first.id;
      await _saveCurrentSectionId();
    }


    await loadStudentsForCurrentSection();
    await loadAttendanceForDate();
    await loadAllAttendance();
    notifyListeners();
  }


  Future<void> reloadAllData() async {
    await initializeSections();
    notifyListeners();
  }

}
