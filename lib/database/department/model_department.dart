import 'package:floor/floor.dart';

@entity
class model_department {
  @PrimaryKey(autoGenerate: false)
  final int? id;

  final String? department_code;
  final String? department_name;

  model_department(
    this.id,
    this.department_code,
    this.department_name,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is model_department &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          department_code == other.department_code &&
          department_name == other.department_name;

  @override
  int get hashCode =>
      id.hashCode ^ department_code.hashCode ^ department_name.hashCode;

  @override
  String toString() {
    return 'model_department{id: $id,department_code: $department_code,department_name: $department_name, }';
  }
}
