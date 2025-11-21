import 'package:Ecogrow/dashboard/pages/personal_info.dart';
import 'package:Ecogrow/dashboard/pages/service/user_service.dart';
import 'package:Ecogrow/dashboard/widgets/logoutDialog.dart';
import 'package:flutter/material.dart';

import '../../authentication/service/auth_service.dart';
import '../../authentication/login_page.dart';
import '../../utility/app_colors.dart';
import '../../utility/storage_service.dart';
import '../../utility/toast.dart';
import '../../utility/widget_utility.dart';
import '../widgets/deleteDialog.dart';
import 'models/user.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.light_gray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------------- HEADER ----------------------
            SizedBox(
              width: screenWidth,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "images/profile.jpg",
                    width: screenWidth,
                    height: 250,
                    fit: BoxFit.cover,
                  ),

                  Container(
                    width: screenWidth,
                    height: 250,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                          Colors.black87,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            "images/user.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Nome utente
                      FutureBuilder<List<String?>>(
                        future: Future.wait([
                          StorageService.getFirstName(),
                          StorageService.getLastName(),
                        ]),
                        builder: (context, snapshot) {
                          var displayName = "EcoGrow User";

                          if (snapshot.connectionState == ConnectionState.done &&
                              snapshot.hasData) {
                            final first = snapshot.data![0] ?? "";
                            final last = snapshot.data![1] ?? "";
                            if ((first + last).trim().isNotEmpty) {
                              displayName = "$first $last";
                            }
                          }

                          return Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------------------- CARDS ----------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // ---------- PERSONAL INFORMATION ----------
                  buildSettingsCardProfile(
                    context,
                    items: [
                      {
                        "icon": Icons.edit,
                        "text": "Personal informations",
                        "onTap": () async {
                          // SHOW LOADER
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.green,
                              ),
                            ),
                          );

                          final userService = UserService();
                          final (ok, message, user) =
                          await userService.getCurrentUser();

                          Navigator.pop(context); // close loader

                          if (!ok || user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    message ?? "Unable to load user data."),
                              ),
                            );
                            return;
                          }

                          // NAVIGATE TO PERSONAL PAGE
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonalPage(
                                name: user.firstName,
                                surname: user.lastName,
                                email: user.email,
                                password: "",
                              ),
                            ),
                          ).then((updated) {
                            if (updated == true) {
                              // Force rebuild
                              showToastCorrect(context, "Profile updated successfully!");
                            }
                          });
                        }
                      },
                      {
                        "icon": Icons.group,
                        "text": "Friends",
                        "onTap": () => debugPrint("Tap: Friends"),
                      },
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ---------- GARDEN CARD ----------
                  buildSettingsCardProfile(
                    context,
                    items: [
                      {
                        "icon": Icons.eco,
                        "text": "Shared plants",
                        "onTap": () => debugPrint("Tap: Shared plants"),
                      },
                      {
                        "icon": Icons.calendar_month,
                        "text": "Calendar view",
                        "onTap": () => debugPrint("Tap: Calendar view"),
                      },
                      {
                        "icon": Icons.share,
                        "text": "Share your garden",
                        "onTap": () => debugPrint("Tap: Share your garden"),
                      },
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ---------- LOGOUT & DELETE ----------
                  buildSettingsCardProfile(
                    context,
                    items: [
                      {
                        "icon": Icons.logout,
                        "text": "Log out",
                        "onTap": () {
                          showDialog(
                            context: context,
                            builder: (_) => LogOutDialog(
                              onConfirm: () async {
                                final auth = AuthService();
                                await auth.logout();

                                Navigator.of(context, rootNavigator: true)
                                    .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                      (route) => false,
                                );
                              },
                              onCancel: () => Navigator.pop(context),
                            ),
                          );
                        },
                        "color": AppColors.black,
                      },
                      {
                        "icon": Icons.delete,
                        "text": "Delete account",
                        "onTap": () {
                          showDialog(
                            context: context,
                            builder: (_) => DeleteAccountDialog(
                              onConfirm: () async {
                                final auth = AuthService();
                                await auth.removeUser();

                                Navigator.of(context, rootNavigator: true)
                                    .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                      (route) => false,
                                );
                              },
                              onCancel: () => Navigator.pop(context),
                            ),
                          );
                        },
                        "color": AppColors.black,
                      },
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
