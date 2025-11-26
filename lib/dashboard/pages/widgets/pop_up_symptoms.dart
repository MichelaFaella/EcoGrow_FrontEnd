import 'package:flutter/material.dart';
import '../../../utility/app_colors.dart';
import '../subpages/symptoms_camera.dart';

Future<List<String>?> showSymptomsPopup(
    BuildContext context,
    List<String> symptoms,
    ) async {
  final List<String> selected = [];

  return showDialog<List<String>>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Theme(
            data: Theme.of(context).copyWith(
              checkboxTheme: CheckboxThemeData(
                side: const BorderSide(color: Colors.white, width: 2),
                fillColor: MaterialStateProperty.resolveWith<Color?>(
                      (states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppColors.green;
                    }
                    return Colors.transparent;
                  },
                ),
                checkColor: MaterialStateProperty.all(Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // -----------------------------------------------------
                // TITLE + CLOSE
                // -----------------------------------------------------
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Which changes did you notice?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // -----------------------------------------------------
                // SYMPTOMS LIST
                // -----------------------------------------------------
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 350),
                  child: SingleChildScrollView(
                    child: Column(
                      children: symptoms.map((sym) {
                        return StatefulBuilder(
                          builder: (_, setState) {
                            final checked = selected.contains(sym);

                            return CheckboxListTile(
                              value: checked,
                              onChanged: (value) {
                                setState(() {
                                  if (checked) {
                                    selected.remove(sym);
                                  } else {
                                    selected.add(sym);
                                  }
                                });
                              },
                              title: Text(
                                sym,
                                style: const TextStyle(color: Colors.white),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // -----------------------------------------------------
                // BUTTON CONFIRM → NAVIGA ALLA CAMERA
                // -----------------------------------------------------
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // chiude il popup

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SymptomCameraPage(symptoms: selected),
                      ),
                    );
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.green,
                          AppColors.orange,
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "CONFIRM",
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      );
    },
  );
}
