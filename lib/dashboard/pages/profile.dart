import 'package:Ecogrow/dashboard/pages/personal_info.dart';
import 'package:Ecogrow/dashboard/widgets/logoutDialog.dart';
import 'package:flutter/material.dart';

import '../../authentication/service/auth_service.dart';
import '../../authentication/login_page.dart';
import '../../utility/app_colors.dart';
import '../../utility/widget_utility.dart';
import '../../utility/storage_service.dart';
import '../widgets/deleteDialog.dart';

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
            // --- SEZIONE IMMAGINE PROFILO ---
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
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black45,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            "images/user.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      FutureBuilder<List<String?>>(
                        future: Future.wait([
                          StorageService.getFirstName(),
                          StorageService.getLastName(),
                        ]),
                        builder: (context, snapshot) {
                          String displayName = "EcoGrow User";

                          if (snapshot.connectionState == ConnectionState.done &&
                              snapshot.hasData) {
                            final first = snapshot.data![0] ?? '';
                            final last = snapshot.data![1] ?? '';
                            final combined = '$first $last'.trim();
                            if (combined.isNotEmpty) {
                              displayName = combined;
                            }
                          }

                          return Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                              color: Colors.white,
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

            // --- SEZIONE CARD ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // --- Card 1 — Info personali ---
                  buildSettingsCardProfile(
                    context,
                    items: [
                      {
                        'icon': Icons.edit,
                        'text': 'Personal informations',
                        'onTap': () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PersonalPage()),
                          );
                        },
                      },
                      {
                        'icon': Icons.group,
                        'text': 'Friends',
                        'onTap': () => debugPrint("Tap: Friends"),
                      },
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Card 2 — Giardino e piante ---
                  buildSettingsCardProfile(
                    context,
                    items: [
                      {
                        'icon': Icons.eco,
                        'text': 'Shared plants',
                        'onTap': () => debugPrint("Tap: Shared plants"),
                      },
                      {
                        'icon': Icons.calendar_month,
                        'text': 'Calendar view',
                        'onTap': () => debugPrint("Tap: Calendar view"),
                      },
                      {
                        'icon': Icons.share,
                        'text': 'Share your garden',
                        'onTap': () => debugPrint("Tap: Share your garden"),
                      },
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Card 3 — Logout / Delete account ---
                  buildSettingsCardProfile(
                    context,
                    items: [
                      // ----------------------- LOGOUT -----------------------
                      {
                        'icon': Icons.logout,
                        'text': 'Log out',
                        'onTap': () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (dialogCtx) {
                              return LogOutDialog(
                                onConfirm: () async {
                                  Navigator.of(dialogCtx).pop(); // chiudi dialog

                                  final auth = AuthService();
                                  await auth.logout();

                                  Navigator.of(context, rootNavigator: true)
                                      .pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) => const LoginPage()),
                                        (route) => false,
                                  );
                                },
                                onCancel: () {
                                  Navigator.of(dialogCtx).pop();
                                },
                              );
                            },
                          );
                        },
                        'color': AppColors.black,
                      },

                      // ------------------ DELETE ACCOUNT -------------------
                      {
                        'icon': Icons.delete,
                        'text': 'Delete account',
                        'onTap': () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (dialogCtx) {
                              return DeleteAccountDialog(
                                onConfirm: () async {
                                  Navigator.of(dialogCtx).pop(); // chiudi dialog

                                  final auth = AuthService();
                                  await auth.removeUser();

                                  Navigator.of(context, rootNavigator: true)
                                      .pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) => const LoginPage()),
                                        (route) => false,
                                  );
                                },
                                onCancel: () {
                                  Navigator.of(dialogCtx).pop();
                                },
                              );
                            },
                          );
                        },
                        'color': AppColors.black,
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
