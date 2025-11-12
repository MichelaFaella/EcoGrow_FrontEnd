import 'package:flutter/material.dart';
import 'package:Ecogrow/dashboard/dashboard_page.dart';
import '../../utility/app_colors.dart';
import '../auth_service.dart';

class RegisterSheet extends StatefulWidget {
  const RegisterSheet({super.key});

  @override
  State<RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends State<RegisterSheet> {
  final AuthService _authService = AuthService();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _surnameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_isLoading &&
          _nameCtrl.text.trim().isNotEmpty &&
          _surnameCtrl.text.trim().isNotEmpty &&
          _emailCtrl.text.trim().isNotEmpty &&
          _pwdCtrl.text.isNotEmpty;

  Future<void> _handleRegister() async {
    if (!_canSubmit) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final (ok, msg) = await _authService.register(
      email: _emailCtrl.text.trim(),
      password: _pwdCtrl.text,
      firstName: _nameCtrl.text.trim(),
      lastName: _surnameCtrl.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      // chiudi il bottom sheet
      Navigator.of(context).pop();

      // poi naviga fuori dal sheet
      Future.microtask(() {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      });
    } else {
      setState(() {
        _errorMessage = msg ?? 'Registration failed';
        _isLoading = false;
      });
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 22),
              const Text(
                "Create Your Account",
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
                      text: "We’re here to help you to take care\nof your plants. ",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 13,
                        fontFamily: "Poppins",
                      ),
                    ),
                    TextSpan(
                      text: "Are you ready?",
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
              const SizedBox(height: 30),

              // NAME
              SizedBox(
                width: 318,
                child: TextField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  cursorColor: AppColors.light_black,
                  decoration: const InputDecoration(
                    hintText: "Enter name",
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
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.red, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.red, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // SURNAME
              SizedBox(
                width: 318,
                child: TextField(
                  controller: _surnameCtrl,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                  cursorColor: AppColors.light_black,
                  decoration: const InputDecoration(
                    hintText: "Enter surname",
                    hintStyle: TextStyle(color: AppColors.dark_gray, fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.dark_gray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.red, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.dark_gray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.red, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // EMAIL
              SizedBox(
                width: 318,
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
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
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.red, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.red, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // PASSWORD
              SizedBox(
                width: 318,
                child: TextField(
                  controller: _pwdCtrl,
                  obscureText: _obscureText,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (_canSubmit) _handleRegister();
                  },
                  cursorColor: AppColors.light_black,
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
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.red, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
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
                  onPressed: _canSubmit ? _handleRegister : null,
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
                        "GET STARTED",
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
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "I HAVE ALREADY AN ACCOUNT",
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
    );
  }
}
