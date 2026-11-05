import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// -------------------- CONSTANTS --------------------
// ⚠️ Replace this with your laptop's IP address (e.g., "http://192.168.1.10:8000")
const String serverIp = "http://172.28.96.1:8000"; // ← change this!

// Theme colors (matching login page)
const Color primaryGreen = Color(0xFF264634);
const Color accentBrown = Color(0xFFB76E4B);
const Color bgColor = Color(0xFFF6F0E2);
const Color cardBg = Colors.white;
const Color borderColor = Color(0xFFEBEBEB);
const Color textDark = Color(0xFF111111);
const Color textGrey = Color(0xFF666666);
const Color textLight = Color(0xFFAAAAAA);

void main() {
  runApp(const SmartPoultryApp());
}

class SmartPoultryApp extends StatefulWidget {
  const SmartPoultryApp({super.key});

  @override
  State<SmartPoultryApp> createState() => _SmartPoultryAppState();
}

class _SmartPoultryAppState extends State<SmartPoultryApp> {
  bool _isAuthenticated = false;
  String _userName = '';
  String _userEmail = '';

  Future<void> _handleLogin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$serverIp/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _isAuthenticated = true;
            _userName = data['name'] ?? email.split('@').first;
            _userEmail = email;
          });
        } else {
          _showErrorDialog(data['message'] ?? 'Échec de la connexion');
        }
      } else {
        _showErrorDialog('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog("Impossible de se connecter au serveur");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
      _userName = '';
      _userEmail = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CoopFeed',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bgColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          surface: cardBg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgColor,
          elevation: 0,
          foregroundColor: primaryGreen,
          titleTextStyle: TextStyle(
            color: primaryGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primaryGreen),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryGreen,
            side: const BorderSide(color: primaryGreen),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: _isAuthenticated
          ? ApplicationFrame(
              onLogout: _handleLogout,
              userName: _userName,
              userEmail: _userEmail,
            )
          : LoginScreen(onLogin: _handleLogin),
    );
  }
}

// ==================== LOGIN SCREEN ====================
class LoginScreen extends StatefulWidget {
  final Future<void> Function(String email, String password) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await widget.onLogin(_emailController.text, _passwordController.text);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/logo.jpg',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGreen.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGreen.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: primaryGreen,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Connexion',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                    side: const BorderSide(color: primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'S\'inscrire',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(color: accentBrown, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 40),
              Text('Ou connectez-vous avec :', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(Icons.g_mobiledata),
                  const SizedBox(width: 20),
                  _socialIcon(Icons.apple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 30, color: Colors.black),
    );
  }
}

// ==================== SIGN UP SCREEN ====================
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$serverIp/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie ! Vous pouvez maintenant vous connecter.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Erreur lors de l\'inscription')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur serveur : ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de contacter le serveur')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Créer un compte',
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Nom complet',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGreen.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGreen.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGreen.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: primaryGreen,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirmer le mot de passe',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGreen.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: primaryGreen,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'S\'inscrire',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Vous avez déjà un compte ?'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Connectez-vous',
                      style: TextStyle(
                        color: accentBrown,
                        fontWeight: FontWeight.bold,
                      ),
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
}

// ==================== APPLICATION FRAME ====================
class ApplicationFrame extends StatefulWidget {
  final VoidCallback onLogout;
  final String userName;
  final String userEmail;
  const ApplicationFrame({
    super.key,
    required this.onLogout,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ApplicationFrame> createState() => _ApplicationFrameState();
}

class _ApplicationFrameState extends State<ApplicationFrame> {
  int _tabIndex = 0;
  Timer? _globalSecurityTimer;
  String _lastKnownStatus = "Clear";

  bool _showNotificationBanner = false;
  String _bannerAlertMessage = "";

  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _views = [
      const ViewDashboard(),
      const ViewPredator(),
      const ViewForecast(),
      ViewProfile(
        onLogout: widget.onLogout,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),
    ];

    _globalSecurityTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (timer) => _checkGlobalSecurityStatus(),
    );
  }

  @override
  void dispose() {
    _globalSecurityTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkGlobalSecurityStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$serverIp/status'))
          .timeout(const Duration(seconds: 1));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String currentStatus = data['predator_status'] ?? "Clear";

        if (currentStatus == "ALERT" && _lastKnownStatus == "Clear") {
          _triggerHeadsUpNotification(
              "Attention : Un rat a été détecté près de la mangeoire !");
        }
        _lastKnownStatus = currentStatus;
      }
    } catch (_) {}
  }

  void _triggerHeadsUpNotification(String message) {
    setState(() {
      _bannerAlertMessage = message;
      _showNotificationBanner = true;
    });

    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() => _showNotificationBanner = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: _tabIndex,
              children: _views,
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              top: _showNotificationBanner ? 12 : -100,
              left: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _tabIndex = 1;
                    _showNotificationBanner = false;
                  });
                },
                child: Material(
                  elevation: 6,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFDC2626),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.gpp_bad,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ALERTE DÉTECTION RAT',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8)),
                              const SizedBox(height: 2),
                              Text(_bannerAlertMessage,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white70, size: 18),
                          onPressed: () =>
                              setState(() => _showNotificationBanner = false),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: borderColor, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: (index) => setState(() => _tabIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: cardBg,
          selectedItemColor: primaryGreen,
          unselectedItemColor: const Color(0xFFCCCCCC),
          selectedLabelStyle: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded), label: 'Tableau de bord'),
            BottomNavigationBarItem(
                icon: Icon(Icons.gpp_maybe), label: 'Prédateur'),
            BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined), label: 'Prévisions'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// ==================== 01 · DASHBOARD ====================
class ViewDashboard extends StatefulWidget {
  const ViewDashboard({super.key});
  @override
  State<ViewDashboard> createState() => _ViewDashboardState();
}

class _ViewDashboardState extends State<ViewDashboard> {
  Map<String, dynamic> _metrics = {};
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDashboardMetrics();
    _refreshTimer = Timer.periodic(
        const Duration(seconds: 2), (_) => _loadDashboardMetrics());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardMetrics() async {
    try {
      final response = await http
          .get(Uri.parse('$serverIp/dashboard'))
          .timeout(const Duration(seconds: 3));
      if (mounted) {
        if (response.statusCode == 200) {
          setState(() {
            _metrics = jsonDecode(response.body);
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (_) {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: primaryGreen));
    }

    int reservoirPercent = _metrics['reservoir_percent'] ?? 72;
    double foodRemaining = (_metrics['food_remaining_kg'] ?? 2.16).toDouble();
    int refillDays = _metrics['refill_days'] ?? 3;
    int chickenCount = _metrics['chicken_count'] ?? 14;
    int fedToday = _metrics['fed_today_grams'] ?? 840;
    int batches = _metrics['feed_batches_today'] ?? 8;
    String predatorStatus = _metrics['predator_status'] ?? "Clear";
    String servoState = _metrics['servo_state'] ?? "Open";
    String feedingMode = _metrics['feeding_mode'] ?? "Automatique";
    double ultrasonicDistance = (_metrics['ultrasonic_distance'] ?? 0.0).toDouble();
    String reservoirLevel = _metrics['reservoir_level'] ?? "Plein";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Mercredi 20 mai',
                      style: TextStyle(
                          fontSize: 11,
                          color: textLight,
                          letterSpacing: 0.4)),
                  Text('Tableau de bord',
                      style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: textDark)),
                ],
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor)),
                child: const Icon(Icons.notifications_outlined,
                    color: textGrey, size: 18),
              )
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('NIVEAU RÉSERVOIR',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFCCCCCC),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8)),
                    Row(
                      children: [
                        Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: predatorStatus == "Clear"
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFFDC2626))),
                        const SizedBox(width: 5),
                        Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF333333))),
                        const SizedBox(width: 5),
                        Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF333333))),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Text('$reservoirPercent%',
                    style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.0)),
                const SizedBox(height: 4),
                Text(
                    '$foodRemaining kg restant · recharge sous ~$refillDays jours',
                    style: const TextStyle(
                        color: Color(0xFFAAAAAA), fontSize: 12)),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: reservoirPercent / 100.0,
                    backgroundColor: const Color(0xFF2A2A2A),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 4,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: [
              _buildStatCell('POULETS', '$chickenCount', 'tous détectés'),
              _buildStatCell('NOURRIS AUJOURD\'HUI', '${fedToday}g',
                  '$batches portions'),
              _buildStatCell('PRÉDATEUR', predatorStatus == 'Clear'
                  ? 'Sécurisé'
                  : 'ALERTE', 'Scan actif',
                  color: predatorStatus == 'Clear'
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626)),
              _buildStatCell('SERVO', servoState == 'Open' ? 'Ouvert' : 'Fermé',
                  'mode auto'),
            ],
          ),

          // ---------- Carte Ultrason ----------
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor)),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: reservoirLevel == "Plein" ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(
                    reservoirLevel == "Plein" ? Icons.check_circle : Icons.warning,
                    color: reservoirLevel == "Plein" ? Colors.green : Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservoirLevel == "Plein" ? '✅ Réservoir plein' : '⚠️ Réservoir vide !',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: reservoirLevel == "Plein" ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      Text(
                        'Distance: ${ultrasonicDistance.toStringAsFixed(1)} cm',
                        style: const TextStyle(fontSize: 12, color: textGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Horaires de distribution',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textDark)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(feedingMode,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D4ED8))),
                      )
                    ],
                  ),
                ),
                _buildScheduleItem(
                    Icons.wb_sunny_outlined, 'Matin', '07:00', '240g'),
                _buildScheduleItem(
                    Icons.wb_twilight, 'Midi', '12:00', '240g'),
                _buildScheduleItem(Icons.nightlight_round_outlined, 'Soir',
                    '18:00', '360g',
                    showBorder: false),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: Text('ACTIVITÉ RÉCENTE',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textLight,
                    letterSpacing: 0.8)),
          ),

          Container(
            decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor)),
            child: Column(
              children: [
                _buildActivityItem(
                    Colors.green, 'Nourri 60g — lot #8', '14:32'),
                _buildActivityItem(
                    Colors.green, 'Nourri 60g — lot #7', '12:15'),
                _buildActivityItem(
                    predatorStatus == "Clear" ? Colors.green : Colors.red,
                    predatorStatus == "Clear"
                        ? 'Périmètre sécurisé'
                        : 'Rat détecté — Alerte envoyée',
                    'En temps réel',
                    showBorder: false),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCell(String title, String mainValue, String subText,
      {Color color = textDark}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 10, color: textLight, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(mainValue,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 3),
          Text(subText,
              style: const TextStyle(fontSize: 10, color: Color(0xFFBBBBBB))),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(IconData icon, String label, String time,
      String amount,
      {bool showBorder = true}) {
    return Container(
      decoration: BoxDecoration(
          border: showBorder
              ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))
              : null),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 15, color: textGrey)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textDark))),
          Text(time,
              style: const TextStyle(fontSize: 12, color: textLight)),
          const SizedBox(width: 10),
          Text(amount,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textDark)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Color indicatorColor, String text, String time,
      {bool showBorder = true}) {
    return Container(
      decoration: BoxDecoration(
          border: showBorder
              ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))
              : null),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Container(
              width: 7,
              height: 7,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: indicatorColor)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 12, color: textDark))),
          Text(time,
              style: const TextStyle(fontSize: 11, color: textLight)),
        ],
      ),
    );
  }
}

// ==================== 02 · PREDATOR ====================
class LiveCameraViewer extends StatefulWidget {
  final String serverIp;
  const LiveCameraViewer({super.key, required this.serverIp});
  @override
  State<LiveCameraViewer> createState() => _LiveCameraViewerState();
}

class _LiveCameraViewerState extends State<LiveCameraViewer> {
  Timer? _frameTimer;
  String _currentFrameUrl = "";

  @override
  void initState() {
    super.initState();
    _refreshFrame();
    _frameTimer = Timer.periodic(
        const Duration(milliseconds: 100), (timer) => _refreshFrame());
  }

  void _refreshFrame() {
    if (mounted) {
      setState(() {
        _currentFrameUrl =
            "$serverIp/snapshot?t=${DateTime.now().millisecondsSinceEpoch}";
      });
    }
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentFrameUrl.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    return Image.network(
      _currentFrameUrl,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.camera_alt_outlined,
                size: 28, color: Color(0xFF444444)),
            SizedBox(height: 5),
            Text('Flux vidéo hors ligne',
                style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class ViewPredator extends StatefulWidget {
  const ViewPredator({super.key});
  @override
  State<ViewPredator> createState() => _ViewPredatorState();
}

class _ViewPredatorState extends State<ViewPredator> {
  List<dynamic> _logs = [];
  String _alertStatus = "Clear";
  Timer? _statusLoop;

  @override
  void initState() {
    super.initState();
    _fetchSystemStatus();
    _statusLoop = Timer.periodic(
        const Duration(seconds: 1), (_) => _fetchSystemStatus());
  }

  @override
  void dispose() {
    _statusLoop?.cancel();
    super.dispose();
  }

  Future<void> _fetchSystemStatus() async {
    try {
      final response = await http.get(Uri.parse('$serverIp/status'));
      if (response.statusCode == 200 && mounted) {
        final body = jsonDecode(response.body);
        setState(() {
          _alertStatus = body['predator_status'] ?? "Clear";
          _logs = body['log'] ?? [];
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    bool unsafeFlag = _alertStatus == "ALERT";
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('YOLOv8 · best.pt',
                      style: TextStyle(fontSize: 11, color: textLight)),
                  Text('Alerte Prédateur',
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w600)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBBF7D0))),
                child: Row(
                  children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFF22C55E))),
                    const SizedBox(width: 5),
                    const Text('EN DIRECT',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                            letterSpacing: 0.5))
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),

          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor)),
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                        height: 148,
                        width: double.infinity,
                        child: LiveCameraViewer(serverIp: serverIp)),
                    Positioned(
                        top: 9,
                        left: 9,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                                color: const Color(0xA6000000),
                                borderRadius: BorderRadius.circular(5)),
                            child: const Text('best.pt · YOLOv8',
                                style: TextStyle(
                                    color: Color(0xFF888888), fontSize: 9)))),
                    Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                                color: const Color(0xA6000000),
                                borderRadius: BorderRadius.circular(5)),
                            child: const Text('640×480',
                                style: TextStyle(
                                    color: Color(0xFF555555), fontSize: 9)))),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                              color: const Color(0x99000000),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF4ADE80))),
                              const SizedBox(width: 5),
                              const Text('ANALYSE EN COURS',
                                  style: TextStyle(
                                      color: Color(0xFF4ADE80),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  color: cardBg,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCamCtrlButton(Icons.pause, 'Pause'),
                      _buildCamCtrlButton(Icons.screenshot, 'Capture'),
                      _buildCamCtrlButton(Icons.switch_camera, 'Inverser'),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: unsafeFlag ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: unsafeFlag ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: unsafeFlag
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                      unsafeFlag ? Icons.gpp_bad : Icons.shield_outlined,
                      color: unsafeFlag ? Colors.red : Colors.green,
                      size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(unsafeFlag ? 'Menace active : Rat détecté !'
                          : 'Aucune menace détectée',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: unsafeFlag
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFF15803D))),
                      Text(unsafeFlag ? 'Alerte d\'urgence émise'
                          : 'Dernier scan : il y a quelques secondes',
                          style: TextStyle(
                              fontSize: 11,
                              color: unsafeFlag
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF22C55E))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                      color: unsafeFlag
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(unsafeFlag ? 'ALERTE' : 'Sain',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: unsafeFlag
                              ? const Color(0xFFB91C1C)
                              : const Color(0xFF15803D))),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('JOURNAL DE DÉTECTION',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textLight,
                  letterSpacing: 0.8)),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor)),
            child: _logs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                        child: Text(
                            'Surveillance continue du périmètre active...',
                            style: TextStyle(fontSize: 12, color: Colors.grey))),
                  )
                : Column(
                    children: List.generate(_logs.length, (index) {
                      final item = _logs[index];
                      final bool isDanger = item['type'] == 'danger';
                      final int confidence = item['conf'] ?? 0;

                      return _buildDetectionLogItem(
                        isDanger ? Colors.red : Colors.green,
                        item['threat'] ?? 'Événement Statut',
                        item['time'] ?? '00:00:00',
                        trailingBadge: confidence > 0 ? '$confidence%' : 'Sain',
                        isClear: !isDanger,
                        showBorder: index != _logs.length - 1,
                      );
                    }),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildCamCtrlButton(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: textGrey, size: 16),
        const SizedBox(height: 3),
        Text(text,
            style: const TextStyle(color: Color(0xFF999999), fontSize: 10)),
      ],
    );
  }

  Widget _buildDetectionLogItem(Color dotColor, String mainText,
      String timestamp,
      {required String trailingBadge, bool isClear = false, bool showBorder = true}) {
    return Container(
      decoration: BoxDecoration(
          border: showBorder
              ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))
              : null),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
              width: 7,
              height: 7,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: dotColor)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mainText,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: isClear ? FontWeight.w400 : FontWeight.w500,
                        color: isClear ? textGrey : textDark)),
                Text(timestamp,
                    style:
                        const TextStyle(fontSize: 10, color: textLight)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isClear ? 9 : 8, vertical: 3),
            decoration: BoxDecoration(
                color: isClear ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20)),
            child: Text(trailingBadge,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isClear
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C))),
          )
        ],
      ),
    );
  }
}

// ==================== 03 · FORECAST ====================
class ViewForecast extends StatefulWidget {
  const ViewForecast({super.key});

  @override
  State<ViewForecast> createState() => _ViewForecastState();
}

class _ViewForecastState extends State<ViewForecast> {
  bool _isLoading = true;
  int _refillDays = 3;
  double _kgNeeded = 1.8;
  String _avgDay = "855g";
  String _weeklyTotal = "5.9 kg";
  List<dynamic> _actualData = [50.0, 58.0, 52.0, 62.0];
  List<dynamic> _predictedData = [58.0, 64.0, 60.0];
  List<dynamic> _listForecast = [];

  @override
  void initState() {
    super.initState();
    _fetchForecastData();
  }

  Future<void> _fetchForecastData() async {
    try {
      final response = await http
          .get(Uri.parse('$serverIp/forecast'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          _refillDays = data['refill_days'] ?? 3;
          _kgNeeded = (data['kg_needed'] ?? 1.8).toDouble();
          _avgDay = data['avg_day'] ?? "855g";
          _weeklyTotal = data['weekly_total'] ?? "5.9 kg";
          _actualData = data['actual'] ?? [50.0, 58.0, 52.0, 62.0];
          _predictedData = data['predicted'] ?? [58.0, 64.0, 60.0];
          _listForecast = data['list_forecast'] ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: primaryGreen));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('LSTM · model.h5',
                      style: TextStyle(fontSize: 11, color: textLight)),
                  Text('Prévisions nourriture',
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w600)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('14 poules',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D4ED8))),
              )
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE))),
            child: Row(
              children: [
                Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(9)),
                    child: const Icon(Icons.history_toggle_off,
                        color: Color(0xFF2563EB), size: 17)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recharge sous ~$_refillDays jours',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D4ED8))),
                    Text('~$_kgNeeded kg requis selon les prédictions',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF3B82F6))),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 14.0, right: 14.0, top: 14.0, bottom: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Perspectives sur 7 jours',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textDark)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildLegendIndicator(
                              const Color(0xFFE5E7EB), 'Réel'),
                          const SizedBox(width: 14),
                          _buildLegendIndicator(
                              const Color(0xFFBFDBFE), 'Prédit'),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: SizedBox(
                    height: 72,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ..._actualData.map((h) => _buildChartBar(
                            (h as num).toDouble(), const Color(0xFFE5E7EB))),
                        ..._predictedData.map((h) => _buildChartBar(
                            (h as num).toDouble(), const Color(0xFFBFDBFE))),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 14.0, right: 14.0, top: 4.0, bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildChartLabel('Lun'),
                      _buildChartLabel('Mar'),
                      _buildChartLabel('Mer'),
                      _buildChartLabel('Jeu'),
                      _buildChartLabel('Ven',
                          activeColor: const Color(0xFF3B82F6)),
                      _buildChartLabel('Sam',
                          activeColor: const Color(0xFF3B82F6)),
                      _buildChartLabel('Dim',
                          activeColor: const Color(0xFF3B82F6)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('PRÉVISIONS JOURNALIÈRES',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textLight,
                  letterSpacing: 0.8)),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor)),
            child: _listForecast.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                        child: Text('Aucune prévision disponible',
                            style: TextStyle(fontSize: 12, color: Colors.grey))),
                  )
                : Column(
                    children: List.generate(_listForecast.length, (index) {
                      final item = _listForecast[index];
                      return _buildDailyForecastItem(
                        item['day'] ?? 'Jour',
                        item['amount'] ?? '0g',
                        showBorder: index != _listForecast.length - 1,
                      );
                    }),
                  ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor)),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Résumé hebdomadaire',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textDark)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _buildSummaryMetricsMeta(
                            'MOYENNE / JOUR', _avgDay)),
                    Expanded(
                        child: _buildSummaryMetricsMeta(
                            'CETTE SEMAINE', _weeklyTotal)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(Color sqColor, String text) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: sqColor, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(text,
            style: const TextStyle(color: textLight, fontSize: 10)),
      ],
    );
  }

  Widget _buildChartBar(double height, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: height,
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4), topRight: Radius.circular(4))),
      ),
    );
  }

  Widget _buildChartLabel(String text,
      {Color activeColor = const Color(0xFFBBBBBB)}) {
    return Expanded(
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: activeColor)));
  }

  Widget _buildDailyForecastItem(String day, String targetAmount,
      {bool showBorder = true}) {
    return Container(
      decoration: BoxDecoration(
          border: showBorder
              ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))
              : null),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day,
              style: const TextStyle(fontSize: 12, color: textGrey)),
          Row(
            children: [
              const Text('prédit',
                  style: TextStyle(fontSize: 10, color: Color(0xFF3B82F6))),
              const SizedBox(width: 8),
              Text(targetAmount,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textDark)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryMetricsMeta(String metricLabel, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(metricLabel,
            style: const TextStyle(
                fontSize: 10, color: textLight, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textDark)),
      ],
    );
  }
}

// ==================== 04 · PROFILE ====================
class ViewProfile extends StatefulWidget {
  final VoidCallback onLogout;
  final String userName;
  final String userEmail;
  const ViewProfile({
    super.key,
    required this.onLogout,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  String _hardwareServoStatus = "Open";

  // --- Changement de mot de passe ---
  Future<void> _changePassword(String email, String oldPw, String newPw) async {
    try {
      final response = await http.post(
        Uri.parse('$serverIp/change-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "old_password": oldPw,
          "new_password": newPw,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mot de passe modifié avec succès'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Erreur')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur serveur : ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de contacter le serveur')),
      );
    }
  }

  void _showChangePasswordDialog() {
    final oldPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Changer le mot de passe'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPwController,
                  obscureText: obscureOld,
                  decoration: InputDecoration(
                    labelText: 'Ancien mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setStateDialog(() => obscureOld = !obscureOld),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: newPwController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setStateDialog(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le nouveau mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setStateDialog(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newPwController.text != confirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
                    );
                    return;
                  }
                  if (newPwController.text.length < 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Le mot de passe doit faire au moins 4 caractères')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  await _changePassword(
                    widget.userEmail,
                    oldPwController.text,
                    newPwController.text,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                child: const Text('Modifier', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paramètres des notifications'),
        content: const Text('Cette fonctionnalité sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateServoManualState(String targetState) async {
    try {
      final response = await http.post(
        Uri.parse('$serverIp/servo/control'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"state": targetState}),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          setState(() => _hardwareServoStatus = body['servo_state']);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: Color(0xFF22C55E), shape: BoxShape.circle),
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 48),

            Text(
              widget.userName.isNotEmpty ? widget.userName : 'Utilisateur',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
            ),
            Text(
              widget.userEmail,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12)),
              child: const Text('Agriculteur',
                  style: TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildProfileOptionRow(
                        Icons.notifications_none_outlined,
                        'Paramètres des notifications',
                        onTap: _showNotificationSettings),
                    _buildProfileOptionRow(
                        Icons.lock_outline, 'Changer le mot de passe',
                        showBorder: false, onTap: _showChangePasswordDialog),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      color: primaryGreen,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Contrôle du servomoteur',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFF27272A),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('Manuel',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFFA1A1AA),
                                    fontWeight: FontWeight.w600)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _updateServoManualState("Open"),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFBBF7D0))),
                                child: Column(
                                  children: const [
                                    Icon(Icons.sensor_door_outlined,
                                        color: Color(0xFF16A34A), size: 18),
                                    SizedBox(height: 2),
                                    Text('Ouvrir l\'accès',
                                        style: TextStyle(
                                            color: Color(0xFF15803D),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => _updateServoManualState("Closed"),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFFECACA))),
                                child: Column(
                                  children: const [
                                    Icon(Icons.disabled_by_default_outlined,
                                        color: Color(0xFFDC2626), size: 18),
                                    SizedBox(height: 2),
                                    Text('Fermer l\'accès',
                                        style: TextStyle(
                                            color: Color(0xFFB91C1C),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 14.0, right: 14.0, bottom: 10.0),
                      child: Row(
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF22C55E))),
                          const SizedBox(width: 6),
                          const Text('Statut : ',
                              style: TextStyle(
                                  fontSize: 11, color: textGrey)),
                          Text(
                              _hardwareServoStatus == "Open" ? "Ouvert" : "Fermé",
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _hardwareServoStatus == "Open"
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB91C1C))),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 24.0),
              child: InkWell(
                onTap: widget.onLogout,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: Colors.redAccent, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Déconnexion',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptionRow(IconData icon, String title,
      {bool showBorder = true, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))
            : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: textGrey, size: 20),
        title: Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textDark)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        dense: true,
        onTap: onTap ?? () {},
      ),
    );
  }
}