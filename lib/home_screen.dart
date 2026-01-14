import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'github_service.dart';
import 'capture_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // CONFIGURATION GITHUB
  final String _githubToken = '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'; 
  final String _owner = 'saboiteau';
  final String _repo = 'mon-assistant-v3-mobile';

  late GitHubService _githubService;

  @override
  void initState() {
    super.initState();
    _githubService = GitHubService(
      token: _githubToken,
      owner: _owner,
      repo: _repo,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Bonjour Sandrine',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
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
              builder: (context) => CaptureScreen(githubService: _githubService),
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
                widthFactor: 0.65,
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
                _buildOrangeButton('Lancer la discussion', Icons.bolt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrangeButton(String text, IconData icon) {
    return Container(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Text(
                    '3 NOUVEAUX',
                    style: TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildVeilleItem('Régulation IA Act : Impact direct', 'Lu il y a 5 min'),
            const Divider(height: 32, color: Colors.white10),
            _buildVeilleItem('Apple Vision Pro 2 : Rumeurs', 'Hier à 18h42'),
            const Divider(height: 32, color: Colors.white10),
            _buildVeilleItem('Shift stratégique du marché', 'Il y a 2 jours'),
          ],
        ),
      ),
    );
  }

  Widget _buildVeilleItem(String title, String subtitle) {
    return Row(
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
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3)),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.white10),
      ],
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
    return GlassCard(
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
                boxShadow: isActive ? [
                  BoxShadow(
                    color: const Color(0xFF135BEC).withOpacity(0.6),
                    blurRadius: 12,
                  )
                ] : null,
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
              _buildNavItem(Icons.grid_view, 'Home', true),
              _buildNavItem(Icons.chat_bubble_outline, 'Chat', false),
              _buildNavItem(Icons.auto_awesome_outlined, 'Briefs', false),
              _buildNavItem(Icons.settings_outlined, 'Réglages', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
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
