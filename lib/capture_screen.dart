import 'package:flutter/material.dart';
import 'github_service.dart';

class CaptureScreen extends StatefulWidget {
  final GitHubService githubService;

  const CaptureScreen({super.key, required this.githubService});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleCapture() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isLoading = true);

    final success = await widget.githubService.pushToVeille(_controller.text);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Envoyé sur GitHub !'),
          backgroundColor: Colors.green,
        ),
      );
      _controller.clear();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Erreur lors de l\'envoi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Capture Rapide'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Que voulez-vous sauvegarder ?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Collez une URL ou écrivez une note pour mon assistant.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                hintText: 'https://...',
                hintStyle: const TextStyle(color: Colors.white24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFFF8C42)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCapture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Envoyer à mon Secret Brain',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
