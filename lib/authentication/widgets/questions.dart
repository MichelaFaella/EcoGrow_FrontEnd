import 'package:flutter/material.dart';
import '../../utility/app_colors.dart';

class QuestionCard extends StatelessWidget {
  final String title;
  final String question;
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onOptionSelected;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final bool isLast;
  final double progress; // 0–1 (es: (currentIndex+1)/8)
  final bool isBehind;   // true se è la card dietro (solo estetica)

  const QuestionCard({
    super.key,
    required this.title,
    required this.question,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.onNext,
    required this.onBack,
    required this.isLast,
    required this.progress,
    required this.isBehind,
  });

  @override
  Widget build(BuildContext context) {
    final hasBack = onBack != null;

    return Transform.translate(
      offset: isBehind ? const Offset(0, 10) : Offset.zero,
      child: Transform.scale(
        scale: isBehind ? 0.97 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────────────────
              // Barra in alto: 4 rettangoli, 8 domande totali (2 per rettangolo)
              // ─────────────────────────────────────────
              Builder(
                builder: (context) {
                  const int totalQuestions = 8;
                  const int blocks = 4;

                  // progress è 0–1, lo mappiamo a step 0..8
                  final int currentStep =
                  ((progress * totalQuestions).clamp(0, totalQuestions))
                      .round();

                  return Row(
                    children: List.generate(blocks, (index) {
                      // ogni blocco copre 2 domande: [0–1], [2–3], [4–5], [6–7]
                      final int blockStartQuestion = index * 2;
                      final int blockQuestionsDone =
                      (currentStep - blockStartQuestion)
                          .clamp(0, 2)
                          .toInt(); // 0..2
                      final double fillFraction =
                          blockQuestionsDone / 2.0; // 0, 0.5, 1

                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: index == blocks - 1 ? 0 : 6,
                          ),
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.light_gray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: fillFraction,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 16),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark_gray,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),

              Text(
                question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: AppColors.black,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'SELECT ONLY ONE',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dark_gray,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 10),

              // ─────────────────────────────────────────
              // Opzioni (RadioListTile)
              // ─────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final opt = options[index];
                    return RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: opt,
                      groupValue: selectedOption,
                      onChanged: isBehind ? null : onOptionSelected,
                      activeColor: AppColors.green,
                      title: Text(
                        opt,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: AppColors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // ─────────────────────────────────────────
              // Bottoni Back / Next- Send a destra
              // ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasBack) ...[
                    TextButton(
                      onPressed: isBehind ? null : onBack,
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.dark_gray,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                  ElevatedButton(
                    onPressed: isBehind ? null : onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(isLast ? 'Send' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
