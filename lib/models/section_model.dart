class Section {
  int? id;
  String name;

  Section({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      // Do not include 'id' when inserting; let SQLite handle it
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'],
      name: map['name'],
    );
  }
}
