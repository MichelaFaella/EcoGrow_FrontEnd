import 'package:Ecogrow/authentication/test.dart';
import 'package:Ecogrow/authentication/widgets/login_sheet.dart';
import 'package:Ecogrow/authentication/widgets/register_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utility/app_colors.dart';
import '../utility/storage_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _showLoginSheet(BuildContext context){
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (context) => const LoginSheet(),
    );
  }

  void _showRegistrationSheet(BuildContext context) async {
    // 1. Apri il bottom sheet di registrazione
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => const RegisterSheet(),
    );

    // Se il foglio è stato chiuso senza registrazione → NON navigare
    if (result != true) return;

    // 2. Reset del flag questionario per il nuovo utente
    await StorageService.clearQuestionnaireFlag();

    // 3. Vai alla pagina TestPage
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const TestPage(),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      backgroundColor: AppColors.black, // sfondo rosso adattivo
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //LOGO
                  Column(
                    children: [
                      Image.asset(
                        "images/EcoGrow.png",
                        height: 90,),
                      const SizedBox(height: 30,),
                      const Text(
                        'Hi there!\nAre you ready to create your digital garden?\nHere you can take care of your plant in an easy, smart\nand eco-friendly way.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30,),
                  Image.asset(
                    "images/mainLogin.png",
                    height: MediaQuery.of(context).size.height*0.4,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),
                  
                  Column(
                    children: [
                      SizedBox(
                        width: 280,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)
                            )
                          ),
                          onPressed: () => _showRegistrationSheet(context),
                          child: const Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              color: AppColors.dark_green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 280,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.white, width: 1.2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)
                                )
                            ),
                            onPressed: () => _showLoginSheet(context),
                            child: const Text(
                              "LOG IN",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                        ),
                      ),

                    ],
                  )
                ],
              ),
            ),
          ),
        )
      )
    );
  }
}

