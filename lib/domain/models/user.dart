/// Класс [User] представляет модель пользователя в системе.
///
/// Поля класса включают:
/// - [id] - уникальный идентификатор пользователя.
/// - [token] - токен доступа пользователя.
/// - [fullName] - полное имя пользователя.
/// - [post] - должность пользователя.
/// - [snils] - СНИЛС пользователя.
/// - [inn] - ИНН пользователя.
/// - [experience] - стаж работы пользователя.
/// - [isPermissonFile] - разрешение на работу с файлами.
/// - [isPermissonAudio] - разрешение на работу с аудио.
/// - [isFirstAudio] - флаг первой проверки аудио.
/// - [isFirstFile] - флаг первой проверки файла.
/// - [department] - подразделение, в котором работает пользователь.
/// - [employmentDate] - дата начала работы.
/// - [project] - проект, над которым работает пользователь.
/// - [status] - статус активности пользователя.
/// - [position] - должность пользователя.
/// - [isProcess] - флаг, включены ли процессы из админки.
/// - [role] - роль пользователя.
///
/// Конструктор класса требует указания всех полей.
///
/// Также класс предоставляет фабричный метод [fromJson], который позволяет
/// создать экземпляр [User] из Map<String, dynamic>.

class User {
  String id;
  String token; // token
  String fullName; // ФИО
  String post; // должность
  String snils; // СНИЛС
  String inn; // ИНН
  int experience; // Стаж работы
  bool isPermissonFile; // разрешение на аудио
  bool isPermissonAudio; // разрешение на аудио
  bool isFirstAudio; // первая проверка аудио
  bool isFirstFile; // первая проверка файла
  String department; // подразделение
  DateTime employmentDate; // employment_date
  String project; // организация
  bool status; // статус
  String position; // должность
  bool isProcess; // включаем ли процессы из админки
  UserRole role; // роль пользователя

  /// Проверка на исполнитель
  bool get isExecutor => role == UserRole.executor;

  /// Проверка на администратор
  bool get isAdministrator => role == UserRole.administrator;

  /// Проверка на менеджер проекта
  bool get isProjectManager => role == UserRole.projectManager;

  User({
    required this.id,
    required this.fullName,
    required this.post,
    required this.snils,
    required this.inn,
    required this.experience,
    required this.token,
    required this.isPermissonFile,
    required this.isPermissonAudio,
    required this.isFirstFile,
    required this.isFirstAudio,
    required this.department,
    required this.employmentDate,
    required this.project,
    required this.status,
    required this.position,
    required this.isProcess,
    required this.role,
  });

  /// Фабричный метод для создания экземпляра [User] из Map<String, dynamic>.
  factory User.fromJson(Map<String, dynamic> data) {
    String error = '';
    for (final item in data.values) {
      error += '/n${item.runtimeType}';
    }
    try {
      DateTime employmentDate = data['employment_date'] == null
          ? DateTime.now()
          : DateTime.parse(data['employment_date']);
      int yearsWorked = calculateWorkYears(employmentDate, DateTime.now());
      return User(
        id: data['id'] == null ? '0' : data['id'].toString(),
        fullName: data['full_name'] ?? '',
        post: data['post'] ?? '',
        snils: data['snils'] ?? '',
        inn: data['inn'] ?? '',
        experience: data['experience'] ?? yearsWorked,
        token: data['token'] ?? '',
        isPermissonFile: data['isPermissonFile'] ?? false,
        isPermissonAudio: data['isPermissonAudio'] ?? false,
        isFirstFile: data['isFirstFile'] ?? true,
        isFirstAudio: data['isFirstAudio'] ?? true,
        department: data['department'] ?? '',
        employmentDate: employmentDate,
        project: data['project'] ?? '',
        status: data['status'] == null
            ? false
            : data['status'] == 1
                ? true
                : false,
        position: data['position'] ?? '',
        isProcess: data['isProcess'] ?? false,
        role: UserRole.values.firstWhere((r) => r.title == data['role'],
            orElse: () => UserRole.executor),
      );
    } catch (e) {
      throw Exception(
          'ошибка парсинге Sz.fromJson == $e \n данные: $data, \n  логи: \n $error');
    }
  }

  /// Инициализация пустого пользователя
  factory User.initial() {
    return User(
      id: '',
      fullName: '',
      post: '',
      snils: '',
      inn: '',
      experience: 0,
      token: '',
      isPermissonFile: false,
      isPermissonAudio: false,
      isFirstFile: true,
      isFirstAudio: true,
      department: '',
      employmentDate: DateTime.now(),
      project: '',
      status: false,
      position: '',
      isProcess: false,
      role: UserRole.executor,
    );
  }

  /// Преобразование пользователя в Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'post': post,
      'snils': snils,
      'inn': inn,
      'experience': experience,
      'token': token,
      'isPermissonFile': isPermissonFile,
      'isPermissonAudio': isPermissonAudio,
      'isFirstFile': isFirstFile,
      'isFirstAudio': isFirstAudio,
      'department': department,
      'employment_date': employmentDate.toString(),
      'project': project,
      'status': status,
      'position': position,
      'isProcess': isProcess,
      'role': role.title,
    };
  }
}

/// Проверка на високосный год
bool isLeapYear(int year) {
  if (year % 4 == 0) {
    if (year % 100 == 0) {
      if (year % 400 == 0) {
        return true;
      }
      return false;
    }
    return true;
  }
  return false;
}

/// Вычисление количества рабочих лет между двумя датами
int calculateWorkYears(DateTime startDate, DateTime endDate) {
  int years = endDate.year - startDate.year;

  if ((endDate.month < startDate.month) ||
      (endDate.month == startDate.month && endDate.day < startDate.day)) {
    years--;
  }

  for (int i = startDate.year; i < endDate.year; i++) {
    if (isLeapYear(i)) {
      years++;
    }
  }

  return years;
}

/// Роли пользователя
enum UserRole {
  executor,
  administrator,
  projectManager;

  String get title {
    switch (this) {
      case UserRole.executor:
        return 'Исполнитель';
      case UserRole.administrator:
        return 'Администратор';
      case UserRole.projectManager:
        return 'Руководитель проекта';
    }
  }
}
