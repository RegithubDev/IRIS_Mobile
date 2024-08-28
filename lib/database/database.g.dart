// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorFlutterDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDatabaseBuilder databaseBuilder(String name) =>
      _$FlutterDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$FlutterDatabaseBuilder(null);
}

class _$FlutterDatabaseBuilder {
  _$FlutterDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$FlutterDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$FlutterDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<FlutterDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$FlutterDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$FlutterDatabase extends FlutterDatabase {
  _$FlutterDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  DepartmentTable? _departmentTable;
  ProjectTable? _projectTable;
  UserTable? _userTable;
  SBUTable? _sbuTable;
  ThemesTable? _themesTable;


  // VisitedTable? _visitedTableInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        /*await database.execute(
            'CREATE TABLE IF NOT EXISTS `model_department` (`department_code` TEXT NOT NULL,`department_name` TEXT NOT NULL,)');

        await database.execute(
            'CREATE TABLE IF NOT EXISTS `model_project` (`project_code` TEXT NOT NULL,`project_name` TEXT NOT NULL,)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `model_user` (`user_code` TEXT NOT NULL,`user_name` TEXT NOT NULL,)');*/

        await database.execute(
            'CREATE TABLE IF NOT EXISTS `model_sbu` (`sbu_code` TEXT NOT NULL,`sbu_name` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `model_department` (`department_code` TEXT NOT NULL,`department_name` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `model_project` (`project_code` TEXT NOT NULL,`project_name` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `model_user` (`user_id` TEXT NOT NULL,`user_name` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `model_themes` (`theme_code` TEXT NOT NULL,`theme_name` TEXT NOT NULL)');
        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  DepartmentTable get modelDepartment {
    return _departmentTable ??= _$DepartmentDao(database, changeListener);
  }

  @override
  ProjectTable get modelProject {
    return _projectTable ??= _$ProjectDao(database, changeListener);
  }

  @override
  SBUTable get modelSBU {
    return _sbuTable ??= _$SBUDao(database, changeListener);
  }

  @override
  UserTable get modelUser {
    return _userTable ??= _$UserDao(database, changeListener);
  }

    @override
    ThemesTable get modelThemes {
      return _themesTable ??= _$ThemesDao(database, changeListener);
    }

}

class _$DepartmentDao extends DepartmentTable {
  final sqflite.DatabaseExecutor m_database;

  final StreamController<String> m_changeListener;

  final QueryAdapter _m_queryAdapter;

  final InsertionAdapter<model_department> _m_taskInsertionAdapter;

  final UpdateAdapter<model_department> _m_taskUpdateAdapter;

  final DeletionAdapter<model_department> _m_taskDeletionAdapter;

  _$DepartmentDao(this.m_database, this.m_changeListener)
      : _m_queryAdapter = QueryAdapter(m_database, m_changeListener),
        _m_taskInsertionAdapter = InsertionAdapter(
            m_database,
            'model_department',
            (model_department item) => <String, Object?>{
                  'department_code': item.department_code,
                  'department_name': item.department_name,
                },
            m_changeListener),
        _m_taskUpdateAdapter = UpdateAdapter(
            m_database,
            'model_department',
            ['department_code'],
            (model_department item) => <String, Object?>{
                  'department_code': item.department_code,
                  'department_name': item.department_name,
                },
            m_changeListener),
        _m_taskDeletionAdapter = DeletionAdapter(
            m_database,
            'model_department',
            ['department_code'],
            (model_department item) => <String, Object?>{
                  'department_code': item.department_code,
                  'department_name': item.department_name,
                },
            m_changeListener);

  @override
  Future<model_department?> findDepartmentById(String department_code) async {
    return _m_queryAdapter
        .query('SELECT * FROM model_department WHERE department_code = ?',
            mapper: (Map<String, Object?> row) => model_department(
                  row['id'] as int?,
                  row['department_code'] as String?,
                  row['department_name'] as String?,
                ),
            arguments: [department_code]);
  }

  @override
  Future<List<model_department>> findAllDepartmentByName(
      String department_name) async {
    return _m_queryAdapter.queryList(
        'SELECT * FROM model_department WHERE department_name LIKE ?',
        mapper: (Map<String, Object?> row) => model_department(
              row['id'] as int?,
              row['department_code'] as String?,
              row['department_name'] as String?,
            ),
        arguments: ['%$department_name']);
  }

  @override
  Future<List<model_department>> findAllDepartments() async {
    return _m_queryAdapter.queryList('SELECT * FROM model_department',
        mapper: (Map<String, Object?> row) => model_department(
            row['id'] as int?,
            row['department_code'] as String?,
            row['department_name'] as String?));
  }

  @override
  Future<void> insertDepartment(model_department dept) async {
    await _m_taskInsertionAdapter.insert(dept, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertDepartments(List<model_department> depts) async {
    await _m_taskInsertionAdapter.insertList(depts, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateDepartment(model_department dept) async {
    await _m_taskUpdateAdapter.update(dept, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateDepartments(List<model_department> dept) async {
    await _m_taskUpdateAdapter.updateList(dept, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteDepartment(model_department dept) async {
    await _m_taskDeletionAdapter.delete(dept);
  }

  @override
  Future<void> deleteDepartments(List<model_department> depts) async {
    await _m_taskDeletionAdapter.deleteList(depts);
  }
}

class _$ProjectDao extends ProjectTable {
  final sqflite.DatabaseExecutor m_database;

  final StreamController<String> m_changeListener;

  final QueryAdapter _m_queryAdapter;

  final InsertionAdapter<model_project> _m_taskInsertionAdapter;

  final UpdateAdapter<model_project> _m_taskUpdateAdapter;

  final DeletionAdapter<model_project> _m_taskDeletionAdapter;

  _$ProjectDao(this.m_database, this.m_changeListener)
      : _m_queryAdapter = QueryAdapter(m_database, m_changeListener),
        _m_taskInsertionAdapter = InsertionAdapter(
            m_database,
            'model_project',
            (model_project item) => <String, Object?>{
                  'project_code': item.project_code,
                  'project_name': item.project_name,
                },
            m_changeListener),
        _m_taskUpdateAdapter = UpdateAdapter(
            m_database,
            'model_project',
            ['project_code'],
            (model_project item) => <String, Object?>{
                  'project_code': item.project_code,
                  'project_name': item.project_name,
                },
            m_changeListener),
        _m_taskDeletionAdapter = DeletionAdapter(
            m_database,
            'model_project',
            ['project_code'],
            (model_project item) => <String, Object?>{
                  'project_code': item.project_code,
                  'project_name': item.project_name,
                },
            m_changeListener);

  @override
  Future<model_project?> findProjectById(String project_code) async {
    return _m_queryAdapter
        .query('SELECT * FROM model_project WHERE project_code = ?',
            mapper: (Map<String, Object?> row) => model_project(
                  row['id'] as int?,
                  row['project_code'] as String?,
                  row['project_name'] as String?,
                ),
            arguments: [project_code]);
  }

  @override
  Future<List<model_project>> findAllProjectsByName(String project_name) async {
    return _m_queryAdapter
        .queryList('SELECT * FROM model_project WHERE project_name LIKE ?',
            mapper: (Map<String, Object?> row) => model_project(
                  row['id'] as int?,
                  row['project_code'] as String?,
                  row['project_name'] as String?,
                ),
            arguments: ['%$project_name']);
  }

  @override
  Future<List<model_project>> findAllProjects() async {
    return _m_queryAdapter.queryList('SELECT * FROM model_project',
        mapper: (Map<String, Object?> row) => model_project(row['id'] as int?,
            row['project_code'] as String?, row['project_name'] as String?));
  }

  @override
  Future<void> insertProject(model_project project) async {
    await _m_taskInsertionAdapter.insert(project, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertProjects(List<model_project> projects) async {
    await _m_taskInsertionAdapter.insertList(
        projects, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateProject(model_project project) async {
    await _m_taskUpdateAdapter.update(project, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateProjects(List<model_project> project) async {
    await _m_taskUpdateAdapter.updateList(project, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteProject(model_project project) async {
    await _m_taskDeletionAdapter.delete(project);
  }

  @override
  Future<void> deleteProjects(List<model_project> projects) async {
    await _m_taskDeletionAdapter.deleteList(projects);
  }
}

class _$UserDao extends UserTable {
  final sqflite.DatabaseExecutor m_database;

  final StreamController<String> m_changeListener;

  final QueryAdapter _m_queryAdapter;

  final InsertionAdapter<model_user> _m_taskInsertionAdapter;

  final UpdateAdapter<model_user> _m_taskUpdateAdapter;

  final DeletionAdapter<model_user> _m_taskDeletionAdapter;

  _$UserDao(this.m_database, this.m_changeListener)
      : _m_queryAdapter = QueryAdapter(m_database, m_changeListener),
        _m_taskInsertionAdapter = InsertionAdapter(
            m_database,
            'model_user',
            (model_user item) => <String, Object?>{
                  'user_id': item.user_id,
                  'user_name': item.user_name,
                },
            m_changeListener),
        _m_taskUpdateAdapter = UpdateAdapter(
            m_database,
            'model_user',
            ['user_id'],
            (model_user item) => <String, Object?>{
                  'user_id': item.user_id,
                  'user_name': item.user_name,
                },
            m_changeListener),
        _m_taskDeletionAdapter = DeletionAdapter(
            m_database,
            'model_user',
            ['user_id'],
            (model_user item) => <String, Object?>{
                  'user_id': item.user_id,
                  'user_name': item.user_name,
                },
            m_changeListener);

  @override
  Future<model_user?> findUserById(String user_code) async {
    return _m_queryAdapter.query('SELECT * FROM model_user WHERE user_id = ?',
        mapper: (Map<String, Object?> row) => model_user(
              row['id'] as int?,
              row['user_id'] as String?,
              row['user_name'] as String?,
            ),
        arguments: [user_code]);
  }

  @override
  Future<List<model_user>> findAllUsersByName(String user_name) async {
    return _m_queryAdapter
        .queryList('SELECT * FROM model_user WHERE user_name LIKE ?',
            mapper: (Map<String, Object?> row) => model_user(
                  row['id'] as int?,
                  row['user_id'] as String?,
                  row['user_name'] as String?,
                ),
            arguments: ['%$user_name']);
  }

  @override
  Future<List<model_user>> findAllUsers() async {
    return _m_queryAdapter.queryList('SELECT * FROM model_user',
        mapper: (Map<String, Object?> row) => model_user(row['id'] as int?,
            row['user_id'] as String?, row['user_name'] as String?));
  }

  @override
  Future<void> insertUser(model_user user) async {
    await _m_taskInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertUsers(List<model_user> users) async {
    await _m_taskInsertionAdapter.insertList(users, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUser(model_user user) async {
    await _m_taskUpdateAdapter.update(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUsers(List<model_user> user) async {
    await _m_taskUpdateAdapter.updateList(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteUser(model_user user) async {
    await _m_taskDeletionAdapter.delete(user);
  }

  @override
  Future<void> deleteUsers(List<model_user> users) async {
    await _m_taskDeletionAdapter.deleteList(users);
  }
}

class _$SBUDao extends SBUTable {
  final sqflite.DatabaseExecutor m_database;

  final StreamController<String> m_changeListener;

  final QueryAdapter _m_queryAdapter;

  final InsertionAdapter<model_sbu> _m_taskInsertionAdapter;

  final UpdateAdapter<model_sbu> _m_taskUpdateAdapter;

  final DeletionAdapter<model_sbu> _m_taskDeletionAdapter;

  _$SBUDao(this.m_database, this.m_changeListener)
      : _m_queryAdapter = QueryAdapter(m_database, m_changeListener),
        _m_taskInsertionAdapter = InsertionAdapter(
            m_database,
            'model_sbu',
            (model_sbu item) => <String, Object?>{
                  'sbu_code': item.sbu_code,
                  'sbu_name': item.sbu_name,
                },
            m_changeListener),
        _m_taskUpdateAdapter = UpdateAdapter(
            m_database,
            'model_sbu',
            ['sbu_code'],
            (model_sbu item) => <String, Object?>{
                  'sbu_code': item.sbu_code,
                  'sbu_name': item.sbu_name,
                },
            m_changeListener),
        _m_taskDeletionAdapter = DeletionAdapter(
            m_database,
            'model_sbu',
            ['sbu_code'],
            (model_sbu item) => <String, Object?>{
                  'sbu_code': item.sbu_code,
                  'sbu_name': item.sbu_name,
                },
            m_changeListener);

  @override
  Future<model_sbu?> findSBUById(String sbu_code) async {
    return _m_queryAdapter.query('SELECT * FROM model_sbu WHERE sbu_code = ?',
        mapper: (Map<String, Object?> row) => model_sbu(
              row['id'] as int?,
              row['sbu_code'] as String?,
              row['sbu_name'] as String?,
            ),
        arguments: [sbu_code]);
  }

  @override
  Future<List<model_sbu>> findAllSBUsByName(String sbu_name) async {
    return _m_queryAdapter
        .queryList('SELECT * FROM model_sbu WHERE sbu_name LIKE ?',
            mapper: (Map<String, Object?> row) => model_sbu(
                  row['id'] as int?,
                  row['sbu_code'] as String?,
                  row['sbu_name'] as String?,
                ),
            arguments: ['%$sbu_name']);
  }

  @override
  Future<List<model_sbu>> findAllSBUs() async {
    return _m_queryAdapter.queryList('SELECT * FROM model_sbu',
        mapper: (Map<String, Object?> row) => model_sbu(row['id'] as int?,
            row['sbu_code'] as String?, row['sbu_name'] as String?));
  }

  @override
  Future<void> insertSBU(model_sbu sbu) async {
    await _m_taskInsertionAdapter.insert(sbu, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertSBUs(List<model_sbu> sbus) async {
    await _m_taskInsertionAdapter.insertList(sbus, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateSBU(model_sbu sbu) async {
    await _m_taskUpdateAdapter.update(sbu, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateSBUs(List<model_sbu> sbu) async {
    await _m_taskUpdateAdapter.updateList(sbu, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteSBU(model_sbu sbu) async {
    await _m_taskDeletionAdapter.delete(sbu);
  }

  @override
  Future<void> deleteSBUs(List<model_sbu> sbus) async {
    await _m_taskDeletionAdapter.deleteList(sbus);
  }
}

class _$ThemesDao extends ThemesTable {
  final sqflite.DatabaseExecutor m_database;

  final StreamController<String> m_changeListener;

  final QueryAdapter _m_queryAdapter;

  final InsertionAdapter<model_themes> _m_taskInsertionAdapter;

  final UpdateAdapter<model_themes> _m_taskUpdateAdapter;

  final DeletionAdapter<model_themes> _m_taskDeletionAdapter;

  _$ThemesDao(this.m_database, this.m_changeListener)
      : _m_queryAdapter = QueryAdapter(m_database, m_changeListener),
        _m_taskInsertionAdapter = InsertionAdapter(
            m_database,
            'model_themes',
                (model_themes item) => <String, Object?>{
              'theme_code': item.theme_code,
              'theme_name': item.theme_name,
            },
            m_changeListener),
        _m_taskUpdateAdapter = UpdateAdapter(
            m_database,
            'model_themes',
            ['theme_code'],
                (model_themes item) => <String, Object?>{
              'theme_code': item.theme_code,
              'theme_name': item.theme_name,
            },
            m_changeListener),
        _m_taskDeletionAdapter = DeletionAdapter(
            m_database,
            'model_themes',
            ['theme_code'],
                (model_themes item) => <String, Object?>{
              'theme_code': item.theme_code,
              'theme_name': item.theme_name,
            },
            m_changeListener);

  @override
  Future<model_themes?> findThemeById(String theme_code) async {
    return _m_queryAdapter
        .query('SELECT * FROM model_themes WHERE theme_code = ?',
        mapper: (Map<String, Object?> row) => model_themes(
          row['id'] as int?,
          row['theme_code'] as String?,
          row['theme_name'] as String?,
        ),
        arguments: [theme_code]);
  }

  @override
  Future<List<model_themes>> findAllThemesByName(String theme_name) async {
    return _m_queryAdapter
        .queryList('SELECT * FROM model_themes WHERE theme_name LIKE ?',
        mapper: (Map<String, Object?> row) => model_themes(
          row['id'] as int?,
          row['theme_code'] as String?,
          row['theme_name'] as String?,
        ),
        arguments: ['%$theme_name']);
  }

  @override
  Future<List<model_themes>> findAllThemes() async {
    return _m_queryAdapter.queryList('SELECT * FROM model_themes',
        mapper: (Map<String, Object?> row) => model_themes(row['id'] as int?,
            row['theme_code'] as String?, row['theme_name'] as String?));
  }

  @override
  Future<void> insertTheme(model_themes theme) async {
    await _m_taskInsertionAdapter.insert(theme, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertThemes(List<model_themes> themes) async {
    await _m_taskInsertionAdapter.insertList(
        themes, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateTheme(model_themes theme) async {
    await _m_taskUpdateAdapter.update(theme, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateThemes(List<model_themes> themes) async {
    await _m_taskUpdateAdapter.updateList(themes, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTheme(model_themes theme) async {
    await _m_taskDeletionAdapter.delete(theme);
  }

  @override
  Future<void> deleteThemes(List<model_themes> themes) async {
    await _m_taskDeletionAdapter.deleteList(themes);
  }

}

