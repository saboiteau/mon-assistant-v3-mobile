import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  final String token;
  final String owner;
  final String repo;
  final String path = 'captures.txt';

  GitHubService({
    required this.token,
    required this.owner,
    required this.repo,
  });

  /// Pushes a new entry (URL or Note) to the GitHub repository.
  Future<bool> pushToVeille(String content) async {
    try {
      final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');
      
      // 1. Get current file data to obtain the 'sha' (required for updates)
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
      } else if (getResponse.statusCode != 404) {
        print('GitHub GET Error: ${getResponse.body}');
        return false;
      }

      // 2. Prepare new content (append with newline)
      final newContent = currentContent.isEmpty 
          ? content 
          : '$currentContent\n$content';
      
      final base64Content = base64.encode(utf8.encode(newContent));

      // 3. Update/Create file
      final putResponse = await http.put(
        url,
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': 'Assistant V3: Nouvelle capture depuis mobile',
          'content': base64Content,
          'sha': sha.isEmpty ? null : sha,
        }),
      );

      if (putResponse.statusCode == 200 || putResponse.statusCode == 201) {
        print('GitHub Push Success!');
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
}
