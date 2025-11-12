import 'package:Ecogrow/authentication/widgets/register_sheet.dart';
import 'package:Ecogrow/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import '../../utility/app_colors.dart';
import '../auth_service.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  bool _obscureText = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      print("Email aggiornata: ${_emailController.text}");
    });

    _passwordController.addListener(() {
      print("Password aggiornata: ${_passwordController.text}");
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showRegistrationSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => const RegisterSheet(),
    );
  }

  bool _isLoading = false;
  String? _errorMessage;


  Future<void> _handleLogin() async {
    print("Email: ${_emailController.text}");
    print("Password: ${_passwordController.text}");

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context); // Chiude il bottom sheet
      Navigator.pushReplacement( // Vai alla home
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      setState(() {
        _errorMessage = "Nome utente o password errati.";
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
                      text: "Welcome back! We miss you so much.\n",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 13,
                        fontFamily: "Poppins",
                      ),
                    ),
                    TextSpan(
                      text:
                      "Are you ready to come back to \nyour digital garden?",
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

              // NAME FIELD
              SizedBox(
                width: 318,
                child: TextField(
                  controller: _emailController,
                  cursorColor: AppColors.light_black,
                  decoration: const InputDecoration(
                    hintText: "Enter name",
                    hintStyle:
                    TextStyle(color: AppColors.dark_gray, fontSize: 14),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: AppColors.dark_gray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: AppColors.dark_gray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // PASSWORD FIELD with eye icon
              SizedBox(
                width: 318,
                child: TextField(
                  controller: _passwordController,
                  cursorColor: AppColors.light_black,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: "Enter password",
                    hintStyle: const TextStyle(
                        color: AppColors.dark_gray, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      BorderSide(color: AppColors.dark_gray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                      BorderSide(color: AppColors.dark_gray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                  onPressed: _isLoading ? null : _handleLogin, // 👈 AGGIUNTO
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
                      child: _isLoading // 👈 AGGIUNTO: loading indicator
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
                  "I DON'T HAVE ALREADY AN ACCOUNT",
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
