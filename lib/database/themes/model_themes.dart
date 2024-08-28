import 'package:floor/floor.dart';

@entity
class model_themes {
  @PrimaryKey(autoGenerate: false)
  final int? id;

  final String? theme_code;
  final String? theme_name;

  model_themes(this.id, this.theme_code, this.theme_name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is model_themes &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              theme_code == other.theme_code &&
              theme_name == other.theme_name;

  @override
  int get hashCode =>
      id.hashCode ^ theme_code.hashCode ^ theme_name.hashCode;

  @override
  String toString() {
    return 'model_themes{id: $id,theme_code: $theme_code,theme_name: $theme_name, }';
  }
}
