import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'github_service.dart';
import 'capture_screen.dart';
import 'models/fiche.dart';
import 'screens/fiche_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // CONFIGURATION GITHUB - Pointe vers le repo principal unifié
  String? _githubToken; 
  final String _owner = 'saboiteau';
  final String _repo = 'MonAssistantIAv2';  // Repo principal pour workflow unifié

  GitHubService? _githubService;
  bool _isLoading = true;
  int _pendingUrlsCount = 0;
  int _fichesThisMonthCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _githubToken = prefs.getString('github_token');
      if (_githubToken != null) {
        _githubService = GitHubService(
          token: _githubToken!,
          owner: _owner,
          repo: _repo,
        );
        _fetchStats();
      }
      _isLoading = false;
    });
  }

  Future<void> _fetchStats() async {
    if (_githubService == null) return;
    try {
      final fiches = await _githubService!.fetchFiches();
      final now = DateTime.now();
      final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      
      final thisMonth = fiches.where((f) => f.path.contains(monthStr)).length;
      
      // Fetch urls-to-process.txt to count pending items
      final urlsContent = await _githubService!.fetchFileContent('urls-to-process.txt');
      final pendingCount = urlsContent.split('\n').where((l) => l.trim().isNotEmpty && !l.startsWith('#') && !l.contains('TRAITÉES')).length;

      setState(() {
        _fichesThisMonthCount = thisMonth;
        _pendingUrlsCount = pendingCount;
      });
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  double get _fluxIntensity {
    if (_fichesThisMonthCount == 0 && _pendingUrlsCount == 0) return 0.5;
    // Calculation: ratio of pending vs processed (clamped to 0.1 - 0.9 range for the bar)
    double ratio = _pendingUrlsCount / (_fichesThisMonthCount + 5); 
    return (0.1 + (ratio * 0.8)).clamp(0.1, 0.9);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('github_token', token);
    _loadSettings();
  }

  Future<void> _resetToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('github_token');
    setState(() {
      _githubToken = null;
      _githubService = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_githubToken == null) {
      return _buildSetupUI();
    }

    return Scaffold(
      body: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Radial Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    Color(0xFF1E1B4B),
                    Color(0xFF0F172A),
                    Color(0xFF020617),
                  ],
                ),
              ),
            ),
            
            // Background Decorative Shapes (Sketchnote Vibe)
            Positioned(
              top: 100,
              left: -50,
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: SketchnoteCirclePainter(),
                  size: const Size(200, 200),
                ),
              ),
            ),

            // Main Content
            Positioned.fill(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildInformationFlux(),
                      const SizedBox(height: 24),
                      _buildCaptureAction(),
                      const SizedBox(height: 24),
                      _buildSparringPartnerCard(),
                      const SizedBox(height: 24),
                      _buildVeilleSection(),
                      const SizedBox(height: 24),
                      _buildActiveAgents(),
                      const SizedBox(height: 120), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  'Bonjour Sandrine',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                // Feature "Logout" cachée/discrète pour changer le token
                Positioned(
                  right: -30,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.logout, size: 16, color: Colors.white30),
                    onPressed: _resetToken,
                    tooltip: 'Changer de Token',
                  ),
                ),
                Positioned(
                  bottom: -2,
                  left: 0,
                  right: 40,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Prête pour vos objectifs ?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
        _buildJoieIndicator(),
      ],
    );
  }

  Widget _buildJoieIndicator() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: 0.85,
            strokeWidth: 3,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF135BEC)),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '85%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              'JOIE',
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 1,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        Opacity(
          opacity: 0.3,
          child: CustomPaint(
            painter: SketchnoteCirclePainter(),
            size: const Size(70, 70),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureAction() {
    return GlassCard(
      width: double.infinity,
      borderRadius: 24,
      borderColor: const Color(0xFFFF8C42).withOpacity(0.5),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CaptureScreen(githubService: _githubService!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C42).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add_link, color: Color(0xFFFF8C42)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Capture Rapide',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'URL ou note pour la veille',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationFlux() {
    return GlassCard(
      height: 100,
      width: double.infinity,
      borderRadius: 32,
      borderColor: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed, size: 18, color: Color(0xFF135BEC)),
                    const SizedBox(width: 8),
                    Text(
                      'Flux d\'informations',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'OPTIMAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF135BEC),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _fluxIntensity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF135BEC), Color(0xFFFF8C42)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFluxLabel('Calme'),
                _buildFluxLabel('Intense'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFluxLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 8,
        letterSpacing: 1,
        color: Colors.white.withOpacity(0.3),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSparringPartnerCard() {
    return GlassCard(
      width: double.infinity,
      borderRadius: 40,
      borderColor: Colors.white.withOpacity(0.1),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF135BEC).withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF135BEC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(Icons.psychology, size: 36, color: Color(0xFF135BEC)),
                    ),
                    Opacity(
                      opacity: 0.2,
                      child: CustomPaint(
                        painter: SketchnoteCirclePainter(),
                        size: const Size(100, 100),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sparring partner',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prêt pour un feedback stratégique\nsur votre dernier projet ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildOrangeButton('Lancer la discussion', Icons.bolt, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sparring Partner en cours de connexion (V3)...')),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupUI() {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Color(0xFF135BEC)),
              const SizedBox(height: 32),
              const Text(
                'Configuration Souveraine',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Entrez votre Token GitHub (PAT) pour activer la capture mobile.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 40),
              _buildOrangeButton('Configurer le Token', Icons.key, null),
            ],
          ),
        ),
      ),
    );
  }

  // Modification pour rendre le bouton cliquable dans le setup
  Widget _buildOrangeButton(String text, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap ?? (_githubToken == null ? () => _showTokenDialog() : null),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFFF8C42),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8C42).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(icon, size: 18),
          ],
        ),
      ),
    );
  }

  void _showTokenDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('GitHub PAT'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'ghp_...',
            hintStyle: TextStyle(color: Colors.white24),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _saveToken(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Widget _buildVeilleSection() {
    return GlassCard(
      borderRadius: 40,
      width: double.infinity,
      borderColor: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 4, backgroundColor: Color(0xFF135BEC)),
                    const SizedBox(width: 10),
                    const Text(
                      'Veille intelligence',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Le compteur sera dynamique plus tard, ou on peut afficher le nombre total
              ],
            ),
            const SizedBox(height: 24),
            
            // LISTE DYNAMIQUE DES FICHES
            FutureBuilder<List<Fiche>>(
              future: _githubService?.fetchFiches(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  );
                }

                if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 12));
                }

                final fiches = snapshot.data ?? [];
                
                if (fiches.isEmpty) {
                  return Text(
                    'Aucune fiche trouvée',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  );
                }

                // Afficher les 10 premières fiches
                final limitedFiches = fiches.take(10).toList();

                return Column(
                  children: [
                    for (int i = 0; i < limitedFiches.length; i++) ...[
                      _buildVeilleItem(limitedFiches[i]),
                      if (i < limitedFiches.length - 1)
                        const Divider(height: 32, color: Colors.white10),
                    ]
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVeilleItem(Fiche fiche) {
    // Nettoyage du nom pour l'affichage (enlève .md et les préfixes potentiels)
    final displayName = fiche.name.replaceAll('.md', '').replaceAll(RegExp(r'^\d{4}-\d{2}-\d{2}-'), '');
    final dateStr = fiche.name.contains('202') ? fiche.name.substring(0, 10) : 'Récemment';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FicheDetailScreen(
              fiche: fiche, 
              githubService: _githubService!,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.article_outlined, size: 20, color: Colors.white38),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildActiveAgents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'AGENTS ACTIFS',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.3),
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.05))),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAgentCard('Ingénieur', 'En ligne', true),
              const SizedBox(width: 12),
              _buildAgentCard('Bibliothécaire', 'Analyse...', false),
              const SizedBox(width: 12),
              _buildAgentCard('Chercheur', 'Veille', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgentCard(String role, String status, bool isActive) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Agent $role : ${isActive ? "Prêt à vous aider." : "En veille."}')),
        );
      },
      child: GlassCard(
        width: 160,
        height: 70,
        borderRadius: 20,
        borderColor: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? const Color(0xFF135BEC) : Colors.white24,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF135BEC).withOpacity(0.6),
                            blurRadius: 12,
                          )
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.3),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
        child: GlassCard(
          height: 80,
          width: double.infinity,
          borderRadius: 36,
          borderColor: Colors.white.withOpacity(0.2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.grid_view, 'Home', true, () {}),
              _buildNavItem(Icons.chat_bubble_outline, 'Chat', false, () {
                // Future: Sparring Partner
              }),
              _buildNavItem(Icons.auto_awesome_outlined, 'Briefs', false, () {
                _showBriefs();
              }),
              _buildNavItem(Icons.settings_outlined, 'Réglages', false, () {
                _showTokenDialog();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF135BEC) : Colors.white.withOpacity(0.3),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? const Color(0xFF135BEC) : Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  void _showBriefs() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Briefs & Index',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<String>(
                  future: _githubService!.fetchFileContent('data/veille/index.md'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    }
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: MarkdownBody(
                          data: snapshot.data ?? 'Index vide.',
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            p: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                            h1: const TextStyle(color: Color(0xFF135BEC), fontSize: 22, fontWeight: FontWeight.bold),
                            h2: const TextStyle(color: Color(0xFF135BEC), fontSize: 18, fontWeight: FontWeight.bold),
                            h3: const TextStyle(color: Color(0xFFFF8C42), fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color borderColor;
  final double? height;
  final double? width;

  const GlassCard({
    required this.child,
    this.borderRadius = 20,
    required this.borderColor,
    this.height,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SketchnoteCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final random = math.Random(42);

    void addPoint(double angle, double radiusX, double radiusY) {
      double rX = radiusX + (random.nextDouble() - 0.5) * 5;
      double rY = radiusY + (random.nextDouble() - 0.5) * 5;
      double x = size.width / 2 + rX * math.cos(angle);
      double y = size.height / 2 + rY * math.sin(angle);
      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    for (double i = 0; i <= 2 * math.pi + 0.1; i += 0.2) {
      addPoint(i, size.width * 0.45, size.height * 0.45);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
