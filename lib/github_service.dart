import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/fiche.dart';

/// Service GitHub unifié pour écrire dans le repo principal MonAssistantIAv2
/// Supporte deux types de capture :
/// - URLs → ajoutées dans la section "A TRAITER" de urls-to-process.txt
/// - Notes/Réflexions → ajoutées dans notes-to-process.txt
class GitHubService {
  final String token;
  final String owner;
  final String repo;

  GitHubService({
    required this.token,
    required this.owner,
    required this.repo,
  });

  /// Détecte si le contenu est une URL
  bool _isUrl(String content) {
    final trimmed = content.trim();
    return trimmed.startsWith('http://') || 
           trimmed.startsWith('https://') ||
           trimmed.startsWith('www.');
  }

  /// Génère un timestamp lisible
  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
           '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// Push une capture (URL ou Note) vers le repo principal
  /// - Si URL → urls-to-process.txt (section A TRAITER)
  /// - Si Note → notes-to-process.txt
  Future<bool> pushToVeille(String content) async {
    final isUrl = _isUrl(content);
    final path = isUrl ? 'urls-to-process.txt' : 'notes-to-process.txt';
    final timestamp = _getTimestamp();
    
    // Format de la nouvelle entrée
    final entry = isUrl 
        ? content.trim()  // URL simple
        : '# [$timestamp] Capture mobile\n$content';  // Note avec timestamp
    
    return await _appendToFile(path, entry, isUrl);
  }

  /// Ajoute du contenu à un fichier sur GitHub
  Future<bool> _appendToFile(String path, String entry, bool isUrl) async {
    try {
      final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');
      
      // 1. Récupérer le contenu actuel du fichier
      final getResponse = await http.get(
        url,
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      String sha = '';
      String currentContent = '';

      if (getResponse.statusCode == 200) {
        final data = json.decode(getResponse.body);
        sha = data['sha'];
        currentContent = utf8.decode(base64.decode(data['content'].replaceAll('\n', '')));
      } else if (getResponse.statusCode == 404) {
        // Fichier n'existe pas, on va le créer
        if (isUrl) {
          currentContent = '# URLs à traiter pour la Veille\n\n# === URLs A TRAITER ===\n';
        } else {
          currentContent = '# Notes et Réflexions à traiter\n\n# === NOTES A TRAITER ===\n';
        }
      } else {
        print('GitHub GET Error: ${getResponse.body}');
        return false;
      }

      // 2. Insérer l'entrée au bon endroit
      String newContent;
      if (isUrl) {
        // Pour les URLs : ajouter juste avant la dernière ligne ou après "A TRAITER"
        final lines = currentContent.split('\n');
        final insertIndex = lines.lastIndexWhere((l) => l.contains('A TRAITER'));
        if (insertIndex >= 0 && insertIndex < lines.length - 1) {
          lines.insert(insertIndex + 1, entry);
          newContent = lines.join('\n');
        } else {
          newContent = '$currentContent\n$entry';
        }
      } else {
        // Pour les notes : ajouter à la fin
        newContent = '$currentContent\n$entry\n';
      }
      
      final base64Content = base64.encode(utf8.encode(newContent));

      // 3. Mettre à jour le fichier
      final putResponse = await http.put(
        url,
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': isUrl 
              ? '📱 Mobile: Nouvelle URL à traiter'
              : '📱 Mobile: Nouvelle note/réflexion',
          'content': base64Content,
          'sha': sha.isEmpty ? null : sha,
        }),
      );

      if (putResponse.statusCode == 200 || putResponse.statusCode == 201) {
        print('GitHub Push Success! ($path)');
        return true;
      } else {
        print('GitHub PUT Error: ${putResponse.body}');
        return false;
      }
    } catch (e) {
      print('GitHub Service Error: $e');
      return false;
    }
  }

  /// Récupère la liste des fiches de veille (recursive)
  /// Utilise l'API Git Tree pour être plus efficace
  Future<List<Fiche>> fetchFiches() async {
    try {
      // 1. Récupérer le SHA de la branche main
      final branchResponse = await http.get(
        Uri.parse('https://api.github.com/repos/$owner/$repo/branches/main'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (branchResponse.statusCode != 200) {
        print('Error fetching branch: ${branchResponse.body}');
        return [];
      }

      final branchData = json.decode(branchResponse.body);
      final treeSha = branchData['commit']['commit']['tree']['sha'];

      // 2. Récupérer l'arbre complet récursivement
      final treeResponse = await http.get(
        Uri.parse('https://api.github.com/repos/$owner/$repo/git/trees/$treeSha?recursive=1'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (treeResponse.statusCode != 200) {
         print('Error fetching tree: ${treeResponse.body}');
         return [];
      }

      final treeData = json.decode(treeResponse.body);
      final List<dynamic> tree = treeData['tree'];

      // 3. Filtrer pour ne garder que les fichiers .md dans data/veille/fiches/
      final fiches = tree.where((node) {
        final path = node['path'] as String;
        return path.startsWith('data/veille/fiches/') && path.endsWith('.md');
      }).map((node) {
        return Fiche(
          name: node['path'].split('/').last, 
          path: node['path'], 
          sha: node['sha']
        );
      }).toList();

      // Trier par path desc (plus récent en haut)
      fiches.sort((a, b) => b.path.compareTo(a.path));

      return fiches;

    } catch (e) {
      print('GitHub Fetch Error: $e');
      return [];
    }
  }

  /// Récupère le contenu brut d'un fichier
  Future<String> fetchFileContent(String path) async {
    try {
      final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3.raw', // Header pour raw content
        },
      );

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      } else {
        return 'Erreur chargement: ${response.statusCode}';
      }
    } catch (e) {
      return 'Erreur réseau: $e';
    }
  }
}
