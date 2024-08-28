import 'package:floor/floor.dart';

import 'model_themes.dart';

@dao
abstract class ThemesTable {
  @Query('SELECT * FROM model_themes WHERE WHERE theme_code = :theme_code')
  Future<model_themes?> findThemeById(String theme_code);

  @Query('SELECT * FROM model_themes WHERE theme_name LIKE ?')
  Future<List<model_themes>> findAllThemesByName(String theme_name);

  @Query('SELECT * FROM model_themes')
  Future<List<model_themes>> findAllThemes();

  @insert
  Future<void> insertTheme(model_themes theme);

  @insert
  Future<void> insertThemes(List<model_themes> themes);

  @update
  Future<void> updateThemes(List<model_themes> themes);

  @delete
  Future<void> updateTheme(model_themes theme);

  @delete
  Future<void> deleteThemes(List<model_themes> themes);
}
