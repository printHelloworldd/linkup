import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TosPage extends StatefulWidget {
  const TosPage({super.key});

  @override
  State<TosPage> createState() => _TosPageState();
}

class _TosPageState extends State<TosPage> {
  String _markdownData = '';

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  // Загрузка MD файла из assets
  Future<void> _loadMarkdown() async {
    String data = await rootBundle.loadString('assets/terms_and_conditions.md');
    setState(() {
      _markdownData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        forceMaterialTransparency: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Markdown(data: _markdownData),
        ),
      ),
    );
  }
}
