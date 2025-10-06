class Section {
  int? id;
  String name;

  Section({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'],
      name: map['name'],
    );
  }
}
