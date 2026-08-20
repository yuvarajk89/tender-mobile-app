import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/brand_logo.dart';
import 'auth_providers.dart';

/// Sign-in screen — a premium, brand-forward layout: the Donda Export mark on a
/// deep gradient, a clean white card, and a gold sign-in button. Credentials are
/// hardcoded for the internal preview (admin / 1234).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _user = TextEditingController(text: 'admin');
  final _pass = TextEditingController(text: '1234');
  bool _busy = false;
  bool _obscure = true;

  // Login is always this branded scheme (independent of app light/dark).
  static const _bgTop = Color(0xFF1B2E7A);
  static const _bgBottom = Color(0xFF07091A);
  static const _gold = Color(0xFFD4A853);
  static const _fieldFill = Color(0xFFF2F4F9);
  static const _ink = Color(0xFF161A2B);

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _busy = true);
    final ok =
        await ref.read(authControllerProvider.notifier).login(_user.text, _pass.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials — use admin / 1234')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.page,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    // Logo with a soft gold glow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withOpacity(0.35),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const BrandLogo(size: 108),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('DONDA EXPORT',
                        style: AppTypography.display.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.5,
                          fontSize: 26,
                        )),
                    const SizedBox(height: 6),
                    Text('Rough-Diamond Tender Evaluation',
                        style: AppTypography.bodyMuted
                            .copyWith(color: Colors.white70)),
                    const SizedBox(height: AppSpacing.xxl),

                    // Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 30,
                              offset: Offset(0, 12)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sign in',
                              style: AppTypography.h1.copyWith(color: _ink)),
                          const SizedBox(height: 2),
                          Text('Welcome back',
                              style: AppTypography.bodyMuted),
                          const SizedBox(height: AppSpacing.lg),
                          _field(
                            controller: _user,
                            label: 'Username',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _field(
                            controller: _pass,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscure: _obscure,
                            trailing: IconButton(
                              icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF9098AE)),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              onPressed: _busy ? null : _login,
                              style: FilledButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: _ink,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusSm),
                                ),
                                textStyle: AppTypography.title,
                              ),
                              child: _busy
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: _ink))
                                  : const Text('Sign in'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Internal preview · admin / 1234',
                        style: AppTypography.caption
                            .copyWith(color: Colors.white54)),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? trailing,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: AppTypography.body.copyWith(color: _ink),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodyMuted,
        prefixIcon: Icon(icon, color: const Color(0xFF9098AE)),
        suffixIcon: trailing,
        filled: true,
        fillColor: _fieldFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: Color(0xFFE2E5EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: Color(0xFFE2E5EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: _gold, width: 1.6),
        ),
      ),
    );
  }
}
