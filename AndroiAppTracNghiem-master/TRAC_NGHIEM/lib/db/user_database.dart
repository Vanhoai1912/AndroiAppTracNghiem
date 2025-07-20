import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_trac_nghiem.db');
    return _database!;
  }

  // hàm kiểm tra trùng mã đề
  static Future<bool> examCodeExists(String code) async {
    final db = await database;
    final result = await db.query(
      'exams',
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    return result.isNotEmpty;
  }


  static Future<void> updateQuestion({
    required int questionId,
    required String questionText,
    required Map<String, String> answers,
    required String correctAnswer,
  }) async {
    final db = await database;

    await db.update(
      'questions',
      {'questionText': questionText},
      where: 'id = ?',
      whereArgs: [questionId],
    );

    for (final entry in answers.entries) {
      await db.update(
        'answers',
        {
          'answerText': entry.value,
          'isCorrect': entry.key == correctAnswer ? 1 : 0,
        },
        where: 'questionId = ? AND answerLabel = ?',
        whereArgs: [questionId, entry.key],
      );
    }
  }

  static Future<void> deleteQuestion(int questionId) async {
    final db = await database;
    await db.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }

  static Future<List<Map<String, dynamic>>> getQuestionsByExamId(int examId) async {
    final db = await database;
    return await db.query('questions', where: 'examId = ?', whereArgs: [examId]);
  }

  static Future<List<Map<String, dynamic>>> getAnswersByQuestionId(int questionId) async {
    final db = await database;
    return await db.query('answers', where: 'questionId = ?', whereArgs: [questionId]);
  }


  static Future<int> updateExam(Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'exams',
      {
        'title': data['title'],
        'subject': data['subject'],
        'deadline': data['deadline'],
        'startTime': data['startTime'],
        'duration': data['duration'],
        'attempts': data['attempts'],
        'showScore': data['showScore'],
        'grade': data['grade'] ?? '',
        'password': data['password'],
      },
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }



  static Future<List<Map<String, dynamic>>> getAllExams() async {
    final db = await database;
    final exams = await db.query('exams', orderBy: 'createdAt DESC');
    List<Map<String, dynamic>> result = [];

    for (var exam in exams) {
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM questions WHERE examId = ?',
        [exam['id']],
      ));

      result.add({
        ...exam,
        'questionCount': count ?? 0,
      });
    }

    return result;
  }

  static Future<void> deleteExam(int id) async {
    final db = await database;
    await db.delete('exam_answers', where: 'resultId IN (SELECT id FROM exam_results WHERE examId = ?)', whereArgs: [id]);
    await db.delete('exam_results', where: 'examId = ?', whereArgs: [id]);
    await db.delete('answers', where: 'questionId IN (SELECT id FROM questions WHERE examId = ?)', whereArgs: [id]);
    await db.delete('questions', where: 'examId = ?', whereArgs: [id]);
    await db.delete('exams', where: 'id = ?', whereArgs: [id]);
  }


  static Future<int> insertQuestionWithAnswers({
    required int examId,
    required String questionText,
    required Map<String, String> answers, // {'A': '...', 'B': '...', ...}
    required String correctAnswer, // 'A', 'B', 'C', or 'D'
  }) async {
    final db = await database;

    // 1. Thêm câu hỏi vào bảng questions
    final questionId = await db.insert('questions', {
      'examId': examId,
      'questionText': questionText,
    });

    // 2. Thêm 4 đáp án vào bảng answers
    for (final entry in answers.entries) {
      await db.insert('answers', {
        'questionId': questionId,
        'answerLabel': entry.key,
        'answerText': entry.value,
        'isCorrect': entry.key == correctAnswer ? 1 : 0,
      });
    }

    return questionId;
  }

  static Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Bảng users
        await db.execute('''
          CREATE TABLE users (
            id INTEGER  PRIMARY KEY AUTOINCREMENT,
            fullName TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            role TEXT NOT NULL,
            gender TEXT,
            phone TEXT,
            avatar TEXT,
            createdAt TEXT  NOT NULL
          )
        ''');

        // Bảng exams
        await db.execute('''
          CREATE TABLE exams (
            id INTEGER  PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            subject TEXT,
            deadline TEXT,
            startTime TEXT,
            duration INTEGER,
            attempts INTEGER,
            showScore INTEGER ,
            createdBy INTEGER NOT NULL,
            createdAt TEXT NOT NULL,
            grade TEXT,
            code TEXT,
            password TEXT,
            FOREIGN KEY (createdBy) REFERENCES users(id)
          )
        ''');

        // Bảng questions
        await db.execute('''
          CREATE TABLE questions (
            id INTEGER  PRIMARY KEY AUTOINCREMENT,
            examId INTEGER  NOT NULL,
            questionText TEXT NOT NULL,
            FOREIGN KEY (examId) REFERENCES exams(id)
          )
        ''');

        // Bảng answers
        await db.execute('''
          CREATE TABLE answers (
            id INTEGER  PRIMARY KEY AUTOINCREMENT,
            questionId INTEGER  NOT NULL,
            answerLabel TEXT NOT NULL,
            answerText TEXT NOT NULL,
            isCorrect INTEGER NOT NULL,
            FOREIGN KEY (questionId) REFERENCES questions(id)
          )
        ''');

        // Bảng exam_results
        await db.execute('''
          CREATE TABLE exam_results (
            id INTEGER  PRIMARY KEY AUTOINCREMENT,
            examId INTEGER  NOT NULL,
            studentId INTEGER  NOT NULL,
            score REAL,
            submittedAt TEXT,
            FOREIGN KEY (examId) REFERENCES exams(id),
            FOREIGN KEY (studentId) REFERENCES users(id)
          )
        ''');

        // Bảng exam_answers
        await db.execute('''
          CREATE TABLE exam_answers (
            id INTEGER  PRIMARY KEY AUTOINCREMENT,
            resultId INTEGER  NOT NULL,
            questionId INTEGER  NOT NULL,
            answerLabel TEXT NOT NULL,
            FOREIGN KEY (resultId) REFERENCES exam_results(id),
            FOREIGN KEY (questionId) REFERENCES questions(id)
          )
        ''');
      },
    );
  }

  // Ví dụ thêm user
  static Future<int> insertUser(
      String fullName,
      String email,
      String password,
      String role,
      String createdAt
      ) async {
    final db = await database;
    return await db.insert('users', {
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
      'gender': '',
      'phone': '',
      'avatar': '',
      'createdAt': createdAt,
    });

  }

  // Ví dụ thêm exam
  static Future<int> insertExam(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('exams', data);
  }
  static Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  static Future<int> updatePassword(String email, String newPassword) async {
    final db = await AppDatabase.database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
  static Future<void> deleteUserByEmail(String email) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }


}
