import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1D2D77);
  static const Color accent = Color(0xFF3498DB);
  static const Color bg = Color(0xFFF4F6F9);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textGrey = Color(0xFF7F8C8D);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color danger = Color(0xFFE74C3C);

  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: accent,
        ),
        scaffoldBackgroundColor: bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: cardBg,
        ),
        useMaterial3: true,
      );
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: const TextStyle(color: AppTheme.textGrey)),
          ],
        ],
      ),
    );
  }
}

class ErrorWidget2 extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorWidget2({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textDark)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c, size: 28),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: c)),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg = Colors.white;
    switch (status.toLowerCase()) {
      case 'active':
      case 'evaluated':
        bg = AppTheme.success;
        break;
      case 'pending':
      case 'submitted':
        bg = AppTheme.warning;
        fg = AppTheme.textDark;
        break;
      case 'under review':
        bg = AppTheme.accent;
        break;
      default:
        bg = AppTheme.textGrey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style:
              TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
