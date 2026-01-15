import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/fiche.dart';
import '../github_service.dart';

class FicheDetailScreen extends StatelessWidget {
  final Fiche fiche;
  final GitHubService githubService;

  const FicheDetailScreen({
    Key? key,
    required this.fiche,
    required this.githubService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          fiche.name.replaceAll('.md', ''),
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: githubService.fetchFileContent(fiche.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Aucun contenu'));
          }

          return Markdown(
            data: snapshot.data!,
            padding: const EdgeInsets.all(16.0),
            selectable: true,
          );
        },
      ),
    );
  }
}
