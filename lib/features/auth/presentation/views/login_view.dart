import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:exquisssita_manager/app/theme/app_colors.dart';
import 'package:exquisssita_manager/app/theme/app_text_styles.dart';
import 'package:exquisssita_manager/app/theme/app_theme.dart';
import 'package:exquisssita_manager/features/auth/presentation/view_models/auth_vm.dart';

/// Pantalla de inicio de sesión.
///
/// Soporta modo claro y oscuro. El layout se adapta a dispositivos móviles.
/// Las credenciales son validadas por el ViewModel antes de enviarse.
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = ref.read(authViewModelProvider.notifier);
    await vm.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    // El router escucha authState y redirige automáticamente si el login es exitoso
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingXl,
              vertical: AppTheme.spacingXxl,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Logo / Identidad ──────────────────────────────────────
                  _buildHeader(theme, isDark),

                  const SizedBox(height: 48),

                  // ── Formulario ────────────────────────────────────────────
                  _buildForm(theme, loginState),

                  // ── Error ─────────────────────────────────────────────────
                  if (loginState.hasError) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    _buildErrorBanner(loginState.failure!.message, theme),
                  ],

                  const SizedBox(height: AppTheme.spacingXl),

                  // ── Botón de login ────────────────────────────────────────
                  _buildLoginButton(loginState, theme),

                  const SizedBox(height: 48),

                  // ── Footer ────────────────────────────────────────────────
                  _buildFooter(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ícono de la taquería
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(70),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('🌮', style: TextStyle(fontSize: 32)),
          ),
        ),

        const SizedBox(height: AppTheme.spacingL),

        Text(
          'Exquisssita',
          style: AppTextStyles.displayLarge.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: AppTheme.spacingXs),

        Text(
          'Sistema administrativo',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(ThemeData theme, AuthLoginState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Email ────────────────────────────────────────────────────────
          Text(
            'Correo electrónico',
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          TextFormField(
            key: const Key('login_email_field'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enabled: !state.isLoading,
            decoration: const InputDecoration(
              hintText: 'correo@ejemplo.com',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa tu correo electrónico';
              }
              if (!value.contains('@')) {
                return 'Correo electrónico inválido';
              }
              return null;
            },
          ),

          const SizedBox(height: AppTheme.spacingL),

          // ── Contraseña ────────────────────────────────────────────────────
          Text(
            'Contraseña',
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          TextFormField(
            key: const Key('login_password_field'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            enabled: !state.isLoading,
            onFieldSubmitted: (_) => _onLogin(),
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        border: Border.all(color: theme.colorScheme.error.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: 18,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(AuthLoginState state, ThemeData theme) {
    return AnimatedScale(
      scale: state.isLoading ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: ElevatedButton(
        key: const Key('login_button'),
        onPressed: state.isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.primary.withAlpha(150),
          elevation: 0,
          shadowColor: theme.colorScheme.primary.withAlpha(80),
        ),
        child: state.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text('Iniciar sesión'),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Center(
      child: Text(
        'Solo personal autorizado',
        style: AppTextStyles.labelSmall.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(80),
        ),
      ),
    );
  }
}
