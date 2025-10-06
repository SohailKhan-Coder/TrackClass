import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/students_model.dart';
import '../models/section_model.dart';
import '../models/attendance_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'attendance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sections (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT,
            section_id INTEGER,
            FOREIGN KEY (section_id) REFERENCES sections(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER,
            date TEXT,
            present INTEGER DEFAULT 0,
            lesson INTEGER DEFAULT 0,
            sabqi INTEGER DEFAULT 0,
            manzil INTEGER DEFAULT 0,
            revision INTEGER DEFAULT 0,
            lessonQuantity TEXT DEFAULT '',
            sabqiQuantity TEXT DEFAULT '',
            manzilQuantity TEXT DEFAULT '',
            revisionQuantity TEXT DEFAULT '',
            FOREIGN KEY (student_id) REFERENCES students(id)
          )
        ''');
      },
      onOpen: (db) async {
        await db.rawUpdate('''
          UPDATE attendance
          SET lessonQuantity = COALESCE(lessonQuantity, ''),
              sabqiQuantity = COALESCE(sabqiQuantity, ''),
              manzilQuantity = COALESCE(manzilQuantity, ''),
              revisionQuantity = COALESCE(revisionQuantity, ''),
              present = COALESCE(present, 0),
              lesson = COALESCE(lesson, 0),
              sabqi = COALESCE(sabqi, 0),
              manzil = COALESCE(manzil, 0),
              revision = COALESCE(revision, 0)
        ''');
      },
    );
  }


  Future<int> insertSection(Section section) async {
    final db = await database;
    return await db.insert('sections', section.toMap());
  }

  Future<List<Section>> getSections() async {
    final db = await database;
    final result = await db.query('sections');
    return result.map((e) => Section.fromMap(e)).toList();
  }


  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getStudents(int sectionId) async {
    final db = await database;
    final result = await db.query(
      'students',
      where: 'section_id = ?',
      whereArgs: [sectionId],
    );
    return result.map((e) => Student.fromMap(e)).toList();
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }


  Future<int> updateStudent(Student student) async {
    final db = await database;
    if (student.id == null) {
      throw Exception('Student.id is null — cannot update without id.');
    }


    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }



  Future<int> insertAttendance(Attendance attendance) async {
    final db = await database;


    final map = <String, dynamic>{
      'student_id': attendance.studentId,
      'date': attendance.date,
      'present': attendance.present,
      'lesson': attendance.lesson,
      'sabqi': attendance.sabqi,
      'manzil': attendance.manzil,
      'revision': attendance.revision,
      'lessonQuantity': attendance.lessonQuantity,
      'sabqiQuantity': attendance.sabqiQuantity,
      'manzilQuantity': attendance.manzilQuantity,
      'revisionQuantity': attendance.revisionQuantity,
    };

    return await db.insert('attendance', map);
  }

  Future<int> updateAttendance(Attendance att) async {
    final db = await database;
    if (att.id == null) {
      throw Exception('Attendance.id is null — cannot update record without id.');
    }

    final map = <String, dynamic>{
      'student_id': att.studentId,
      'date': att.date,
      'present': att.present,
      'lesson': att.lesson,
      'sabqi': att.sabqi,
      'manzil': att.manzil,
      'revision': att.revision,
      'lessonQuantity': att.lessonQuantity,
      'sabqiQuantity': att.sabqiQuantity,
      'manzilQuantity': att.manzilQuantity,
      'revisionQuantity': att.revisionQuantity,
    };

    return await db.update(
      'attendance',
      map,
      where: 'id = ?',
      whereArgs: [att.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await database;
    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAttendanceFields(
      int id, {
        bool clearLesson = false,
        bool clearSabqi = false,
        bool clearManzil = false,
        bool clearRevision = false,
      }) async {
    final db = await database;

    Map<String, dynamic> values = {};
    if (clearLesson) {
      values['lesson'] = 0;
      values['lessonQuantity'] = '';
    }
    if (clearSabqi) {
      values['sabqi'] = 0;
      values['sabqiQuantity'] = '';
    }
    if (clearManzil) {
      values['manzil'] = 0;
      values['manzilQuantity'] = '';
    }
    if (clearRevision) {
      values['revision'] = 0;
      values['revisionQuantity'] = '';
    }

    if (values.isEmpty) return 0;

    return await db.update('attendance', values, where: 'id = ?', whereArgs: [id]);
  }


  Future<List<Attendance>> getAttendanceByDate(String date, int sectionId) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT a.* 
      FROM attendance a
      JOIN students s ON a.student_id = s.id
      WHERE a.date = ? AND s.section_id = ?
    ''', [date, sectionId]);

    return result.map((e) => Attendance.fromMap(e)).toList();
  }


  Future<List<Attendance>> getAttendanceByStudent(int studentId) async {
    final db = await database;
    final result = await db.query(
      'attendance',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
    return result.map((e) => Attendance.fromMap(e)).toList();
  }


  Future<List<Attendance>> getAttendanceByStudentAndDate(int studentId, {String? date}) async {
    final db = await database;

    String where = 'student_id = ?';
    final List<dynamic> whereArgs = [studentId];

    if (date != null && date.isNotEmpty) {
      where += ' AND date = ?';
      whereArgs.add(date);
    }

    final result = await db.query(
      'attendance',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return result.map((e) => Attendance.fromMap(e)).toList();
  }


  Future<List<Attendance>> getAttendanceByStudentAndRange(
      int studentId, String startDate, String endDate) async {
    final db = await database;
    final maps = await db.query(
      'attendance',
      where: 'student_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [studentId, startDate, endDate],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Attendance.fromMap(m)).toList();
  }


  Future<List<Attendance>> getAttendanceBySection(int sectionId) async {
    final db = await database;
    final result = await db.query(
      'attendance',
      where: 'student_id IN (SELECT id FROM students WHERE section_id = ?)',
      whereArgs: [sectionId],
    );
    return result.map((e) => Attendance.fromMap(e)).toList();
  }

  Future<Map<String, dynamic>> exportToJson() async {
    final db = await database;

    final sections = await db.query('sections');
    final students = await db.query('students');
    final attendance = await db.query('attendance');

    return {
      'sections': sections,
      'students': students,
      'attendance': attendance,
    };
  }

  Future<void> importFromJson(Map<String, dynamic> data) async {
    final db = await database;


    await db.delete('attendance');
    await db.delete('students');
    await db.delete('sections');


    if (data['sections'] != null) {
      for (var sec in data['sections']) {
        await db.insert('sections', Map<String, dynamic>.from(sec));
      }
    }


    if (data['students'] != null) {
      for (var stu in data['students']) {
        await db.insert('students', Map<String, dynamic>.from(stu));
      }
    }


    if (data['attendance'] != null) {
      for (var att in data['attendance']) {
        await db.insert('attendance', Map<String, dynamic>.from(att));
      }
    }
  }
}