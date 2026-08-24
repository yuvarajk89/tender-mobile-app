import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/brand_logo.dart';
import 'auth_providers.dart';

/// Modern sign-in screen: brand mark on a deep gradient, a clean glass-ish card,
/// username/password, a gold primary button, and "Continue with Google"
/// (UI-only demo). Credentials for the preview: admin / 1234.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _user = TextEditingController(text: 'admin');
  final _pass = TextEditingController(text: '1234');
  bool _busy = false;
  bool _googleBusy = false;
  bool _obscure = true;

  static const _bgTop = Color(0xFF23347F);
  static const _bgMid = Color(0xFF141C44);
  static const _bgBottom = Color(0xFF07091A);
  static const _gold = Color(0xFFD4A853);
  static const _fieldFill = Color(0xFFF4F6FB);
  static const _ink = Color(0xFF161A2B);
  static const _muted = Color(0xFF6E7488);

  // Official Google "G".
  static const _googleG = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
<path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
<path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
<path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
<path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>''';

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _busy = true);
    final ok = await ref
        .read(authControllerProvider.notifier)
        .login(_user.text, _pass.text);
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

  Future<void> _google() async {
    setState(() => _googleBusy = true);
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleBusy = false);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgTop, _bgMid, _bgBottom],
            stops: [0, 0.5, 1],
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
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: _gold.withOpacity(0.35),
                              blurRadius: 44,
                              spreadRadius: 4),
                        ],
                      ),
                      child: const BrandLogo(size: 100),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('DONDA EXPORT',
                        style: AppTypography.display.copyWith(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontSize: 25)),
                    const SizedBox(height: 4),
                    Text('Rough-Diamond Tender Evaluation',
                        style: AppTypography.bodyMuted
                            .copyWith(color: Colors.white70)),
                    const SizedBox(height: AppSpacing.xl),

                    // Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 34,
                              offset: Offset(0, 14)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back',
                              style: AppTypography.h1.copyWith(color: _ink)),
                          const SizedBox(height: 2),
                          Text('Sign in to continue',
                              style: AppTypography.bodyMuted
                                  .copyWith(color: _muted)),
                          const SizedBox(height: AppSpacing.lg),

                          // Google — primary modern option
                          _googleButton(),
                          const SizedBox(height: AppSpacing.lg),
                          _orDivider(),
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
                                  color: _muted),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              child: Text('Forgot password?',
                                  style: AppTypography.caption
                                      .copyWith(color: _muted)),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              onPressed: _busy ? null : _login,
                              style: FilledButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: _ink,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm)),
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

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _googleBusy ? null : _google,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFDADCE0)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
        ),
        child: _googleBusy
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.string(_googleG, width: 20, height: 20),
                  const SizedBox(width: 12),
                  Text('Continue with Google',
                      style: AppTypography.title
                          .copyWith(color: const Color(0xFF3C4043))),
                ],
              ),
      ),
    );
  }

  Widget _orDivider() {
    return Row(children: [
      const Expanded(child: Divider(color: Color(0xFFE2E5EF))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('or', style: AppTypography.caption.copyWith(color: _muted)),
      ),
      const Expanded(child: Divider(color: Color(0xFFE2E5EF))),
    ]);
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
        labelStyle: AppTypography.bodyMuted.copyWith(color: _muted),
        prefixIcon: Icon(icon, color: _muted),
        suffixIcon: trailing,
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
