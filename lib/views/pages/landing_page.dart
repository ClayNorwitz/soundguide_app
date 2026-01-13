import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundguide_app/constants/app_colors.dart';
import 'package:soundguide_app/constants/persona_config.dart';
import 'package:soundguide_app/providers/auth_provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _onPersonaTap(BuildContext context, UserType userType) {
    final authProvider = context.read<AuthProvider>();
    authProvider.selectPersona(userType);
    _expandController.forward();
  }

  void _onBackPress(BuildContext context) {
    _expandController.reverse();
    final authProvider = context.read<AuthProvider>();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        authProvider.selectPersona(UserType.goer);
        authProvider.selectPersona(UserType.organiser);
        authProvider.selectPersona(UserType.performer);
        authProvider.logout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isPersonaSelected = authProvider.selectedUserType != null;

        if (isPersonaSelected) {
          return _buildExpandedView(context, authProvider);
        } else {
          return _buildSplitScreenView(context);
        }
      },
    );
  }

  Widget _buildSplitScreenView(BuildContext context) {
    const personas = [UserType.goer, UserType.organiser, UserType.performer];

    return Scaffold(
      body: Container(
        color: AppColors.darkBg,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: List.generate(personas.length, (index) {
            final userType = personas[index];
            final info = PersonaConfig.getInfo(userType);
            final personaAccent = PersonaConfig.getAccentColor(userType);

            return Expanded(
              child: Column(
                children: [
                  // Clickable persona card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onPersonaTap(context, userType),
                      child: Container(
                        color: AppColors.darkBg,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon and title
                            Icon(info.icon, size: 48, color: personaAccent),
                            const SizedBox(height: 16),
                            Text(
                              info.title,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              info.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Divider between personas
                  if (index < personas.length - 1)
                    Container(height: 1, color: AppColors.divider),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildExpandedView(BuildContext context, AuthProvider authProvider) {
    final userType = authProvider.selectedUserType!;
    final info = PersonaConfig.getInfo(userType);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(decoration: BoxDecoration(gradient: info.gradient)),
          // Dark overlay
          Container(color: AppColors.darkBg.withValues(alpha: 0.6)),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => _onBackPress(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // Auth form with fade-in animation
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _expandAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Consumer<AuthProvider>(
                          builder: (context, provider, _) {
                            final personaAccent = PersonaConfig.getAccentColor(
                              userType,
                            );
                            return Column(
                              children: [
                                Icon(info.icon, size: 56, color: personaAccent),
                                const SizedBox(height: 24),
                                Text(
                                  info.title,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  info.description,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _expandAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildAuthForm(context, authProvider, userType),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm(
    BuildContext context,
    AuthProvider authProvider,
    UserType userType,
  ) {
    final emailController = TextEditingController(text: 'test@soundguide.co');
    final passwordController = TextEditingController(text: '123456');
    final nameController = TextEditingController(text: 'Clay');
    final confirmPasswordController = TextEditingController(text: '123456');
    final personaAccent = PersonaConfig.getAccentColor(userType);
    bool isSignup = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            // Error message
            if (authProvider.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.error, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        authProvider.clearError();
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

            // Name field (signup only)
            if (isSignup)
              Column(
                children: [
                  TextField(
                    controller: nameController,
                    enabled: !authProvider.isLoading,
                    cursorColor: personaAccent,
                    cursorWidth: 2.0,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.cardBg.withValues(alpha: 0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: personaAccent),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Email field
            TextField(
              controller: emailController,
              enabled: !authProvider.isLoading,
              keyboardType: TextInputType.emailAddress,
              cursorColor: personaAccent,
              cursorWidth: 2.0,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.cardBg.withValues(alpha: 0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: personaAccent),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: passwordController,
              enabled: !authProvider.isLoading,
              obscureText: true,
              cursorColor: personaAccent,
              cursorWidth: 2.0,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.cardBg.withValues(alpha: 0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: personaAccent),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password field (signup only)
            if (isSignup)
              Column(
                children: [
                  TextField(
                    controller: confirmPasswordController,
                    enabled: !authProvider.isLoading,
                    obscureText: true,
                    cursorColor: personaAccent,
                    cursorWidth: 2.0,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.cardBg.withValues(alpha: 0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: personaAccent),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              )
            else
              const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: Builder(
                builder: (context) {
                  final personaAccent = PersonaConfig.getAccentColor(userType);
                  return ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            // Validate confirm password on signup
                            if (isSignup &&
                                passwordController.text !=
                                    confirmPasswordController.text) {
                              authProvider.errorMessage !=
                                  null; // Trigger error via provider
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }

                            final route = PersonaConfig.getInfo(userType).route;
                            final navigator = Navigator.of(context);

                            final success = await authProvider.authenticate(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                              isSignup: isSignup,
                              name: isSignup
                                  ? nameController.text.trim()
                                  : null,
                            );

                            if (!mounted) return;
                            if (success) {
                              navigator.pushReplacementNamed(route);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: personaAccent,
                      disabledBackgroundColor: AppColors.divider.withValues(
                        alpha: 0.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        : Text(
                            isSignup ? 'Create Account' : 'Login',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  );
                },
              ),
            ),

            if (isSignup) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.divider)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          final route = PersonaConfig.getInfo(userType).route;
                          final navigator = Navigator.of(context);
                          final success = await authProvider.signInWithGoogle();
                          if (success && mounted) {
                            navigator.pushReplacementNamed(route);
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(
                    Icons.g_mobiledata,
                    color: AppColors.white,
                    size: 30,
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            // ------------------------------
            const SizedBox(height: 16),

            // Sign Up / Login toggle
            GestureDetector(
              onTap: !authProvider.isLoading
                  ? () => setState(() => isSignup = !isSignup)
                  : null,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: isSignup
                          ? 'Already have an account? '
                          : 'Don\'t have an account? ',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: isSignup ? 'Login' : 'Sign Up',
                      style: TextStyle(
                        color: personaAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin-dashboard');
              },
              child: const Text('Admin Dashboard'),
            ),
          ],
        );
      },
    );
  }
}
