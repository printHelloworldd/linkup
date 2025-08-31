import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class ReleaseNotesScreen extends StatefulWidget {
  const ReleaseNotesScreen({super.key});

  @override
  _ReleaseNotesScreenState createState() => _ReleaseNotesScreenState();
}

class _ReleaseNotesScreenState extends State<ReleaseNotesScreen> {
  String releaseNotes = "Загрузка нововведений..."; // Значение по умолчанию

  @override
  void initState() {
    super.initState();
    _loadReleaseNotes();
  }

  // Загружаем нововведения из Remote Config
  Future<void> _loadReleaseNotes() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

    try {
      // Пытаемся загрузить новые данные
      await remoteConfig.fetch(); // Устанавливаем срок действия данных
      await remoteConfig.activate(); // Активируем новые данные

      // Получаем текст нововведений из Remote Config
      String fetchedReleaseNotes = remoteConfig.getString('release_notes');
      setState(() {
        releaseNotes = fetchedReleaseNotes.isNotEmpty
            ? fetchedReleaseNotes
            : "Нет нововведений.";
      });
    } catch (e) {
      print("Ошибка при получении данных: $e");
      setState(() {
        releaseNotes = "Не удалось загрузить нововведения.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Что нового?")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(releaseNotes),
      ),
    );
  }
}
