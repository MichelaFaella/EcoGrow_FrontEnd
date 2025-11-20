import 'package:Ecogrow/dashboard/pages/service/user_service.dart';
import 'package:Ecogrow/utility/storage_service.dart';
import 'package:Ecogrow/utility/app_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/textfield.dart';

class PersonalPage extends StatefulWidget {
  final String userId;   // <--- AGGIUNTO
  final String name;
  final String surname;
  final String email;
  final String password;

  const PersonalPage({
    super.key,
    required this.userId,
    required this.name,
    required this.surname,
    required this.email,
    required this.password,
  });

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  late TextEditingController nameCtrl;
  late TextEditingController surnameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController passwordCtrl;

  bool showPassword = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.name);
    surnameCtrl = TextEditingController(text: widget.surname);
    emailCtrl = TextEditingController(text: widget.email);
    passwordCtrl = TextEditingController(text: widget.password);
  }

  Future<void> _saveChanges() async {
    if (saving) return;

    setState(() => saving = true);

    final userService = UserService();

    final (ok, message) = await userService.updateUser(
      userId: widget.userId,
      firstName: nameCtrl.text.trim(),
      lastName: surnameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text.trim().isEmpty ? null : passwordCtrl.text.trim(),
    );

    setState(() => saving = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? "Update failed"),
        ),
      );
      return;
    }

    // Aggiorna dati nello Storage
    await StorageService.saveUserInfo(
      firstName: nameCtrl.text.trim(),
      lastName: surnameCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Updated successfully"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppColors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "Change your data",
                        style: TextStyle(
                          color: AppColors.white,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  LabeledTextField(
                    label: "Name",
                    controller: nameCtrl,
                    hint: '',
                  ),

                  const SizedBox(height: 20),

                  LabeledTextField(
                    label: "Surname",
                    controller: surnameCtrl,
                    hint: '',
                  ),

                  const SizedBox(height: 20),

                  LabeledTextField(
                    label: "Email",
                    controller: emailCtrl,
                    hint: '',
                  ),

                  const SizedBox(height: 20),

                  LabeledTextField(
                    label: "Password",
                    controller: passwordCtrl,
                    obscure: !showPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => showPassword = !showPassword),
                    ),
                    hint: '',
                  ),

                  const SizedBox(height: 200),

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
                      onPressed: saving ? null : _saveChanges,
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
                          child: saving
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            "CONFIRM",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
