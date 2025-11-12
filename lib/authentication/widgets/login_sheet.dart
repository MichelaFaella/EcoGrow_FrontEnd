import 'package:Ecogrow/authentication/widgets/register_sheet.dart';
import 'package:Ecogrow/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import '../../utility/app_colors.dart';
import '../../utility/toast.dart';
import '../auth_service.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Validazioni
  final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  // Password forte: >=8, 1 minuscola, 1 maiuscola, 1 numero, 1 speciale, no spazi
  static const int _minPasswordLen = 8;
  final RegExp _passwordRegex =
  RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9])\S{8,}$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showRegistrationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => const RegisterSheet(),
    );
  }

  Future<void> _handleLogin() async {
    // 1) valida
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      Toast.show(
        context,
        message: "Please fix the highlighted fields",
        type: ToastType.info,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 2) chiama il service (salva già il token)
    final (ok, msg) = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (ok) {
      // 3) toast successo + chiudi sheet + naviga
      Toast.show(
        context,
        message: "Welcome back!",
        type: ToastType.success,
        duration: const Duration(seconds: 2),
      );

      Navigator.of(context).pop();
      Future.microtask(() {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      });
    } else {
      setState(() {
        _errorMessage = msg ?? "Incorrect username or password";
        _isLoading = false;
      });
      Toast.show(
        context,
        message: _errorMessage!,
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 22),
                const Text(
                  "Log In",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(height: 8),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Welcome back! We miss you so much.\n",
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 13,
                          fontFamily: "Poppins",
                        ),
                      ),
                      TextSpan(
                        text: "Are you ready to come back to \nyour digital garden?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          fontSize: 13,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // EMAIL
                SizedBox(
                  width: 318,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username, AutofillHints.email],
                    cursorColor: AppColors.light_black,
                    decoration: const InputDecoration(
                      hintText: "Enter email",
                      hintStyle: TextStyle(color: AppColors.dark_gray, fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.dark_gray, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.dark_gray, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.red, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.red, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Email is required';
                      if (!_emailRegex.hasMatch(value)) return 'Invalid email';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // PASSWORD
                SizedBox(
                  width: 318,
                  child: TextFormField(
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    cursorColor: AppColors.light_black,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: "Enter password",
                      hintStyle: const TextStyle(color: AppColors.dark_gray, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.dark_gray, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.dark_gray, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.red, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.red, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.dark_gray,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    validator: (v) {
                      final value = v ?? '';
                      if (value.isEmpty) return 'Password is required';
                      if (value.length < _minPasswordLen) {
                        return 'Min $_minPasswordLen characters';
                      }
                      if (!_passwordRegex.hasMatch(value)) {
                        return 'Use upper, lower, number & special';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // BUTTON
                SizedBox(
                  width: 318,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.green, AppColors.orange],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "LOG IN",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 200), () {
                      _showRegistrationSheet(context);
                    });
                  },
                  child: const Text(
                    "I DON'T HAVE AN ACCOUNT",
                    style: TextStyle(
                      fontFamily: "Poppins_Semibold",
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
