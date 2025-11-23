import 'dart:io' show Platform;

import 'package:Ecogrow/dashboard/pages/add_friends.dart';
import 'package:Ecogrow/dashboard/pages/generate_pdf.dart';
import 'package:Ecogrow/dashboard/pages/personal_info.dart';
import 'package:Ecogrow/dashboard/pages/service/user_service.dart';
import 'package:Ecogrow/dashboard/widgets/logoutDialog.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import '../../authentication/login_page.dart';
import '../../authentication/service/auth_service.dart';
import '../../utility/app_colors.dart';
import '../../utility/storage_service.dart';
import '../../utility/toast.dart';
import '../../utility/widget_utility.dart';
import '../widgets/deleteDialog.dart';
import 'models/user.dart';
import 'service/reminder_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // =====================================================
  //   APRE L'APP CALENDARIO DI SISTEMA (QUANDO POSSIBILE)
  // =====================================================
  Future<void> _openSystemCalendar() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Android: content://com.android.calendar/time/<millis>
    final uriAndroid = Uri.parse('content://com.android.calendar/time/$now');

    // iOS: calshow:<seconds> (qui uso millis / 1000)
    final uriIOS = Uri.parse('calshow:${now ~/ 1000}');

    final uri = Platform.isIOS ? uriIOS : uriAndroid;

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // =====================================================
  //   CARICA I watering_plan_id GIÀ PRESENTI NEL CALENDARIO
  //   (per evitare duplicati)
  // =====================================================
  Future<Set<String>> _loadExistingPlanIdsFromCalendar(
      DeviceCalendarPlugin plugin,
      String calendarId,
      ) async {
    debugPrint("[CAL] Loading existing events from calendarId=$calendarId");

    final now = DateTime.now();
    // Finestra ampia: da 1 anno fa a 2 anni avanti
    final start = now.subtract(const Duration(days: 365));
    final end = now.add(const Duration(days: 730));

    final eventsResult = await plugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(
        startDate: start,
        endDate: end,
      ),
    );

    debugPrint(
      "[CAL] retrieveEvents → success=${eventsResult.isSuccess}, "
          "errors=${eventsResult.errors}, count=${eventsResult.data?.length}",
    );

    final existingPlanIds = <String>{};

    if (eventsResult.isSuccess && eventsResult.data != null) {
      for (final ev in eventsResult.data!) {
        final desc = ev.description ?? "";
        // Cerco la riga col nostro marcatore: plan_id=...
        final match = RegExp(r'plan_id=([0-9a-fA-F\-]+)').firstMatch(desc);
        if (match != null) {
          final planId = match.group(1);
          if (planId != null && planId.isNotEmpty) {
            existingPlanIds.add(planId);
          }
        }
      }
    }

    debugPrint("[CAL] Existing plan_ids in calendar: $existingPlanIds");
    return existingPlanIds;
  }

  // =====================================================
  //   SYNC WATERING PLANS -> DEVICE CALENDAR (NO DUPLICATI)
  // =====================================================
  Future<void> _syncEventsToCalendar(
      BuildContext context,
      List<Map<String, dynamic>> events,
      ) async {
    debugPrint(
        "[CAL] ================= _syncEventsToCalendar START =================");
    debugPrint("[CAL] Received ${events.length} events from backend");

    // Log grezzo di tutti gli eventi ricevuti
    for (final e in events) {
      debugPrint("[CAL] Raw event from backend: $e");
    }

    if (events.isEmpty) {
      showToastInfo(context, "No watering plans found to sync");
      debugPrint("[CAL] No events → abort sync");
      return;
    }

    final plugin = DeviceCalendarPlugin();

    // 1) Permessi calendario
    debugPrint("[CAL] Checking calendar permissions…");
    var permissions = await plugin.hasPermissions();
    debugPrint(
      "[CAL] hasPermissions → success=${permissions.isSuccess}, "
          "data=${permissions.data}",
    );

    if (!(permissions.isSuccess && (permissions.data ?? false))) {
      debugPrint("[CAL] Requesting permissions…");
      permissions = await plugin.requestPermissions();
      debugPrint(
        "[CAL] requestPermissions → success=${permissions.isSuccess}, "
            "data=${permissions.data}",
      );

      if (!(permissions.isSuccess && (permissions.data ?? false))) {
        showToastWrong(context, "Calendar permission denied");
        debugPrint("[CAL] Permission denied → abort");
        return;
      }
    }

    // 2) Recupero calendari disponibili
    debugPrint("[CAL] Retrieving calendars…");
    final calendarsResult = await plugin.retrieveCalendars();
    debugPrint(
      "[CAL] retrieveCalendars → success=${calendarsResult.isSuccess}, "
          "errors=${calendarsResult.errors}",
    );

    final calendars = calendarsResult.data;
    if (calendars == null || calendars.isEmpty) {
      showToastWrong(context, "No calendars available on this device");
      debugPrint("[CAL] No calendars available → abort");
      return;
    }

    // DEBUG: quali calendari hai?
    debugPrint("[CAL] Found ${calendars.length} calendars:");
    for (final c in calendars) {
      debugPrint(
        "[CAL]  - id=${c.id}, name=${c.name}, "
            "accountName=${c.accountName}, accountType=${c.accountType}, "
            "isReadOnly=${c.isReadOnly}, isDefault=${c.isDefault}",
      );
    }

    // 3) Tieni solo calendari NON read-only
    final writableCalendars =
    calendars.where((c) => !(c.isReadOnly ?? false)).toList();

    debugPrint("[CAL] Writable calendars count = ${writableCalendars.length}");

    if (writableCalendars.isEmpty) {
      showToastWrong(context, "No writable calendars found");
      debugPrint("[CAL] No writable calendars → abort");
      return;
    }

    // 4) Preferisci un calendario Google se possibile
    final googleCalendars = writableCalendars
        .where((c) => (c.accountType ?? "").contains("com.google"))
        .toList();

    debugPrint(
      "[CAL] Google-like calendars count = ${googleCalendars.length} "
          "(accountType contains 'com.google')",
    );

    Calendar targetCalendar;

    if (googleCalendars.isNotEmpty) {
      targetCalendar = googleCalendars.firstWhere(
            (c) => c.isDefault ?? false,
        orElse: () => googleCalendars.first,
      );
      debugPrint(
          "[CAL] Using GOOGLE calendar as target (default if possible).");
    } else {
      targetCalendar = writableCalendars.firstWhere(
            (c) => c.isDefault ?? false,
        orElse: () => writableCalendars.first,
      );
      debugPrint(
          "[CAL] No Google calendar writable → using first writable/default.");
    }

    if (targetCalendar.id == null) {
      showToastWrong(context, "Selected calendar has no valid ID");
      debugPrint("[CAL] targetCalendar.id is null → abort");
      return;
    }

    debugPrint(
      "[CAL] TARGET CALENDAR → id=${targetCalendar.id}, name=${targetCalendar.name}, "
          "accountType=${targetCalendar.accountType}, accountName=${targetCalendar.accountName}",
    );

    // 4.5) Carico i watering_plan già presenti per evitare duplicati
    final existingPlanIds =
    await _loadExistingPlanIdsFromCalendar(plugin, targetCalendar.id!);

    // 5) Creazione eventi
    int successCount = 0;
    int failCount = 0;
    int skippedExistingCount = 0;

    for (final e in events) {
      debugPrint("[CAL] -------- Processing event JSON: $e");

      // ID del watering_plan (chiave per evitare duplicati)
      final planId = (e['id'] as String?) ?? '';

      // Se il planId è già nel calendario, skippa
      if (planId.isNotEmpty && existingPlanIds.contains(planId)) {
        debugPrint(
            "[CAL] Skipping event because plan_id=$planId is already in calendar");
        skippedExistingCount++;
        continue;
      }

      // Info extra (se il backend le manda)
      final plantName = (e['plant_name'] as String?) ?? 'Your plant';
      final waterLevel = (e['water_level'] as String?) ?? '';
      final size = (e['size'] as String?) ?? '';

      // Titolo più descrittivo
      final title = "Water $plantName";

      final startStr = e['start'] as String?;
      if (startStr == null) {
        debugPrint("[CAL] Event skipped: missing 'start' field");
        continue;
      }

      debugPrint("[CAL] Parsing start date: $startStr");

      DateTime dtStart;
      try {
        dtStart = DateTime.parse(startStr);
        debugPrint("[CAL] Parsed date OK → $dtStart");
      } catch (_) {
        debugPrint("[CAL] Invalid date string from backend: $startStr");
        continue;
      }

      final intervalDays = (e['interval_days'] as num?)?.toInt() ?? 3;
      final notesRaw = (e['notes'] as String?) ?? '';

      // Costruisco la description con:
      // - eventuali note dal backend
      // - info pianta
      // - marcatore univoco plan_id=...
      final buffer = StringBuffer();

      if (notesRaw.trim().isNotEmpty) {
        buffer.writeln(notesRaw.trim());
        buffer.writeln();
      }

      if (waterLevel.isNotEmpty || size.isNotEmpty) {
        buffer.writeln("Plant info:");
        if (waterLevel.isNotEmpty) {
          buffer.writeln("- Water level: $waterLevel");
        }
        if (size.isNotEmpty) {
          buffer.writeln("- Size: $size");
        }
        buffer.writeln();
      }

      if (planId.isNotEmpty) {
        buffer.writeln("[EcoGrow] plan_id=$planId");
      }

      final description = buffer.toString().trim();

      debugPrint(
        "[CAL] interval_days=$intervalDays, title='$title', desc='$description'",
      );

      final tzStart = tz.TZDateTime.from(dtStart, tz.local);
      final tzEnd = tzStart.add(const Duration(minutes: 15));

      debugPrint("[CAL] TZ start=$tzStart, TZ end=$tzEnd");

      final event = Event(
        targetCalendar.id,
        title: title,
        description: description,
        start: tzStart,
        end: tzEnd,
        recurrenceRule: RecurrenceRule(
          RecurrenceFrequency.Daily,
          interval: intervalDays,
        ),
      );

      debugPrint("[CAL] Creating/updating event in calendar…");
      final result = await plugin.createOrUpdateEvent(event);

      debugPrint(
        "[CAL] createOrUpdateEvent → success=${result?.isSuccess}, "
            "errors=${result?.errors}, data=${result?.data}",
      );

      if (result?.isSuccess ?? false) {
        successCount++;
        if (planId.isNotEmpty) {
          existingPlanIds.add(planId);
        }
      } else {
        failCount++;
      }
    }

    debugPrint(
      "[CAL] Events created/updated: success=$successCount, "
          "failed=$failCount, skippedExisting=$skippedExistingCount",
    );

    // Se non ho creato nulla, ma ho skippato eventi perché già presenti → tutto ok, apro lo stesso
    if (successCount == 0 && skippedExistingCount > 0) {
      showToastInfo(context, "All watering reminders are already synced");
      debugPrint(
          "[CAL] All events already present in calendar → open calendar anyway");
      debugPrint("[CAL] Opening system calendar app…");
      await _openSystemCalendar();
      debugPrint(
          "[CAL] ================= _syncEventsToCalendar END =================");
      return;
    }

    // Nessun evento creato e nessuno riconosciuto come già presente → errore
    if (successCount == 0) {
      showToastWrong(context, "No watering reminders could be synced");
      debugPrint(
          "[CAL] No events were successfully created and no existing plan_id found → abort open calendar");
      return;
    }

    // Ho creato almeno un evento nuovo
    showToastCorrect(context, "Watering reminders synced!");
    debugPrint("[CAL] Opening system calendar app…");
    await _openSystemCalendar();

    debugPrint(
        "[CAL] ================= _syncEventsToCalendar END =================");
  }


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

                          if (snapshot.connectionState ==
                              ConnectionState.done &&
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
                                  message ?? "Unable to load user data.",
                                ),
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
                              showToastCorrect(
                                context,
                                "Profile updated successfully!",
                              );
                            }
                          });
                        }
                      },
                      {
                        "icon": Icons.group,
                        "text": "Friends",
                        "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFriendsPage())),
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
                        "onTap": () async {
                          // 1) Mostro loader
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.green,
                              ),
                            ),
                          );

                          final reminderService = ReminderService();
                          final (ok, message, events) =
                          await reminderService
                              .fetchWateringPlansForCalendar();

                          Navigator.pop(context); // chiude loader

                          if (!ok || events == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  message ??
                                      'Unable to load watering plans for calendar',
                                ),
                              ),
                            );
                            return;
                          }

                          await _syncEventsToCalendar(context, events);
                        },
                      },
                      {
                        "icon": Icons.share,
                        "text": "Share your garden",
                        "onTap": () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GeneratePdfPage(),
                            ),
                          );
                        },
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
                                final userService = UserService();
                                final ok = await userService.removeUser();

                                if (!context.mounted) return;

                                if (ok) {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                        (route) => false,
                                  );
                                } else {
                                  Navigator.pop(context); // chiudi dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Errore nella cancellazione dell’account',
                                      ),
                                    ),
                                  );
                                }
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
