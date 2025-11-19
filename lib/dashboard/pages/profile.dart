import 'package:Ecogrow/dashboard/widgets/logoutDialog.dart';
import 'package:flutter/material.dart';

import '../../authentication/service/auth_service.dart';
import '../../authentication/login_page.dart';
import '../../utility/app_colors.dart';
import '../../utility/widget_utility.dart';
import '../../utility/storage_service.dart'; // <-- IMPORT AGGIUNTO
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
                      // NOME + COGNOME da StorageService
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

                  // --- Card 3 — Eliminazione account / logout ---
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
                              onConfirm: () async {
                                debugPrint("Log out");

                                // chiudo il dialog
                                Navigator.of(ctx).pop();

                                // cancello token + user info
                                final auth = AuthService();
                                await auth.logout();

                                // porto l'utente alla LoginPage
                                Navigator.of(context, rootNavigator: true)
                                    .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const LoginPage()),
                                      (route) => false,
                                );
                              },
                              onCancel: () {
                                debugPrint("Log out annullata");
                                Navigator.of(ctx).pop();
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
                            builder: (ctx) {
                              final navigator = Navigator.of(ctx, rootNavigator: true);

                              return DeleteAccountDialog(
                                onConfirm: () async {
                                  debugPrint("Account eliminato");

                                  // chiudo il dialog
                                  navigator.pop();

                                  // cancello utente via API + storage
                                  final auth = AuthService();
                                  await auth.removeUser();

                                  // porto l'utente alla LoginPage
                                  navigator.pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const LoginPage()),
                                        (route) => false,
                                  );
                                },
                                onCancel: () {
                                  debugPrint("Cancellazione annullata");
                                  navigator.pop();
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
