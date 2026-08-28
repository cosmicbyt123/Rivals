import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.onLogin});

  final Future<void> Function(String email, String password)? onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _gold = Color(0xFFFFC83D);
  static const _background = Color(0xFF101010);
  static const _surface = Color(0xFF191919);
  static const _muted = Color(0xFFB9B3A8);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.onLogin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login is not connected to Supabase yet.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onLogin!(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      color: _gold,
                      size: 52,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'WELCOME BACK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Train harder. Rise higher.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 42),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        label: 'Email address',
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Enter your email address.';
                        }

                        if (!RegExp(
                          r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
                        ).hasMatch(email)) {
                          return 'Enter a valid email address.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        label: 'Password',
                        icon: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _muted,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password.';
                        }

                        if (value.length < 8) {
                          return 'Password must be at least 8 characters.';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: const Color(0xFF80651F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'New to Rivals? ',
                          style: TextStyle(color: _muted),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            'Create an account',
                            style: TextStyle(
                              color: _gold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted),
      hintText: label,
      hintStyle: const TextStyle(color: _muted),
      prefixIcon: Icon(icon, color: _gold),
      filled: true,
      fillColor: _surface,
      errorStyle: const TextStyle(color: Color(0xFFFF8A80)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF303030)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF8A80)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 1.5),
      ),
    );
  }
}
