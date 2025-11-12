import 'package:Ecogrow/dashboard/widgets/logoutDialog.dart';
import 'package:flutter/material.dart';

import '../../utility/app_colors.dart';
import '../../utility/widget_utility.dart';
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
                  // Sfondo immagine
                  Image.asset(
                    "images/profile.jpg",
                    width: screenWidth,
                    height: 250,
                    fit: BoxFit.cover,
                  ),

                  // Layer gradiente (non blocca i tocchi)
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

                  // Cerchio con immagine profilo + nome
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
                      const Text(
                        "Michela Faella",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- SEZIONE CARD ---
            const SizedBox(height: 30),
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
                          debugPrint("Tap: Personal informations");
                        },
                      },
                      {
                        'icon': Icons.group,
                        'text': 'Friends',
                        'onTap': () {
                          debugPrint("Tap: Friends");
                        },
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
                        'onTap': () {
                          debugPrint("Tap: Shared plants");
                        },
                      },
                      {
                        'icon': Icons.calendar_month,
                        'text': 'Calendar view',
                        'onTap': () {
                          debugPrint("Tap: Calendar view");
                        },
                      },
                      {
                        'icon': Icons.share,
                        'text': 'Share your garden',
                        'onTap': () {
                          debugPrint("Tap: Share your garden");
                        },
                      },
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Card 3 — Eliminazione account ---
                  buildSettingsCardProfile(
                    context,
                    items: [
                      {
                        'icon': Icons.logout,
                        'text': 'Log out',
                        'onTap': () {
                          debugPrint("Tap: Log out account");
                          showDialog(
                            context: context,
                            useRootNavigator: true,
                            barrierDismissible: true,
                            builder: (ctx) => LogOutDialog(
                              onConfirm: () {
                                debugPrint("Log out");
                              },
                              onCancel: () {
                                debugPrint("Log out annullata");
                              },
                            ),
                          );
                        },
                        'color': AppColors.black,
                      },
                      {
                        'icon': Icons.delete,
                        'text': 'Delete account',
                        'onTap': () {
                          debugPrint("Tap: Delete account");
                          showDialog(
                            context: context,
                            useRootNavigator: true,
                            barrierDismissible: true,
                            builder: (ctx) => DeleteAccountDialog(
                              onConfirm: () {
                                debugPrint("Account eliminato");
                              },
                              onCancel: () {
                                debugPrint("Cancellazione annullata");
                              },
                            ),
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
