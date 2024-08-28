import 'package:floor/floor.dart';

@entity
class model_sbu {
  @PrimaryKey(autoGenerate: false)
  final int? id;

  final String? sbu_code;
  final String? sbu_name;

  model_sbu(this.id, this.sbu_code, this.sbu_name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is model_sbu &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sbu_code == other.sbu_code &&
          sbu_name == other.sbu_name;

  @override
  int get hashCode => id.hashCode ^ sbu_code.hashCode ^ sbu_name.hashCode;

  @override
  String toString() {
    return 'model_sbu{id: $id,sbu_code: $sbu_code,sbu_name: $sbu_name, }';
  }
}
