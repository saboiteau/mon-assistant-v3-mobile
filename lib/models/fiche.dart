class Fiche {
  final String name;
  final String path;
  final String sha;
  final String? downloadUrl;

  Fiche({
    required this.name,
    required this.path,
    required this.sha,
    this.downloadUrl,
  });

  factory Fiche.fromJson(Map<String, dynamic> json) {
    return Fiche(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      sha: json['sha'] ?? '',
      downloadUrl: json['download_url'],
    );
  }
}
