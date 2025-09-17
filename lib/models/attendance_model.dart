class Attendance {
  final int? id;
  final int studentId;
  final String date;
  final int present;
  final int lesson;
  final int sabqi;
  final int manzil;
  final int revision;
  final String lessonQuantity;
  final String sabqiQuantity;
  final String manzilQuantity;
  final String revisionQuantity;

  Attendance({
    this.id,
    required this.studentId,
    required this.date,
    this.present = 0,
    this.lesson = 0,
    this.sabqi = 0,
    this.manzil = 0,
    this.revision = 0,
    this.lessonQuantity = '',
    this.sabqiQuantity = '',
    this.manzilQuantity = '',
    this.revisionQuantity = '',
  });

  Attendance copyWith({
    int? id,
    int? studentId,
    String? date,
    int? present,
    int? lesson,
    int? sabqi,
    int? manzil,
    int? revision,
    String? lessonQuantity,
    String? sabqiQuantity,
    String? manzilQuantity,
    String? revisionQuantity,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      present: present ?? this.present,
      lesson: lesson ?? this.lesson,
      sabqi: sabqi ?? this.sabqi,
      manzil: manzil ?? this.manzil,
      revision: revision ?? this.revision,
      lessonQuantity: lessonQuantity ?? this.lessonQuantity,
      sabqiQuantity: sabqiQuantity ?? this.sabqiQuantity,
      manzilQuantity: manzilQuantity ?? this.manzilQuantity,
      revisionQuantity: revisionQuantity ?? this.revisionQuantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'date': date,
      'present': present,
      'lesson': lesson,
      'sabqi': sabqi,
      'manzil': manzil,
      'revision': revision,
      'lessonQuantity': lessonQuantity,
      'sabqiQuantity': sabqiQuantity,
      'manzilQuantity': manzilQuantity,
      'revisionQuantity': revisionQuantity,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      date: map['date'] as String,
      present: map['present'] ?? 0,
      lesson: map['lesson'] ?? 0,
      sabqi: map['sabqi'] ?? 0,
      manzil: map['manzil'] ?? 0,
      revision: map['revision'] ?? 0,
      lessonQuantity: map['lessonQuantity'] ?? '',
      sabqiQuantity: map['sabqiQuantity'] ?? '',
      manzilQuantity: map['manzilQuantity'] ?? '',
      revisionQuantity: map['revisionQuantity'] ?? '',
    );
  }

  @override
  String toString() =>
      'Attendance(id: $id, studentId: $studentId, date: $date, present: $present, lesson: $lesson, sabqi: $sabqi, manzil: $manzil, revision: $revision, lessonQuantity: $lessonQuantity, sabqiQuantity: $sabqiQuantity, manzilQuantity: $manzilQuantity, revisionQuantity: $revisionQuantity)';
}
