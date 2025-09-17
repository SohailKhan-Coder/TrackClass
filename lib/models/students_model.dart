class Student {
  final int? id;
  final String name;
  final String? phone;
  final int sectionId;

  Student({
    this.id,
    required this.name,
    this.phone,
    required this.sectionId,
  });

  Student copyWith({int? id, String? name, String? phone, int? sectionId}) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      sectionId: sectionId ?? this.sectionId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'section_id': sectionId,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      sectionId: map['section_id'],
    );
  }

  @override
  String toString() =>
      'Student(id: $id, name: $name, phone: $phone, sectionId: $sectionId)';
}
