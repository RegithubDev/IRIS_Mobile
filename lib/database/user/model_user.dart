import 'package:floor/floor.dart';

@entity
class model_user {
  @PrimaryKey(autoGenerate: false)
  final int? id;
  final String? user_id;
  final String? user_name;

  model_user(this.id, this.user_id, this.user_name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is model_user &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          user_id == other.user_id &&
          user_name == other.user_name;

  @override
  int get hashCode => id.hashCode ^ user_id.hashCode ^ user_name.hashCode;

  @override
  String toString() {
    return 'model_user{id: $id,user_id: $user_id,user_name: $user_name, }';
  }
}
