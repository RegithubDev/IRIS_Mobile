import 'package:floor/floor.dart';

@entity
class model_project {
  @PrimaryKey(autoGenerate: false)
  final int? id;

  final String? project_code;
  final String? project_name;

  model_project(this.id, this.project_code, this.project_name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is model_project &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          project_code == other.project_code &&
          project_name == other.project_name;

  @override
  int get hashCode =>
      id.hashCode ^ project_code.hashCode ^ project_name.hashCode;

  @override
  String toString() {
    return 'model_project{id: $id,project_code: $project_code,project_name: $project_name, }';
  }
}
