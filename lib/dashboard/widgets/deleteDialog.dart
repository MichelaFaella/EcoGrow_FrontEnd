import 'package:flutter/material.dart';

import '../../utility/app_colors.dart';

class DeleteAccountDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DeleteAccountDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      title: const Text(
        "Are you sure that you want to delete your account?",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontFamily: "Poppins",
          color: Colors.black87,
        ),
      ),
      content: const Text(
        "This action will be permanent and you will lose your entire garden.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontFamily: "Poppins",
          color: Colors.black54,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            minimumSize: const Size(100, 45),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text("YES", style: TextStyle(fontFamily: "Poppins", color: AppColors.white)),
        ),
        const SizedBox(width: 10,),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            minimumSize: const Size(100, 45),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(); // chiude sempre
            onCancel();
          },
          child: const Text("NO", style: TextStyle(fontFamily: "Poppins", color: AppColors.white)),
        ),
      ],
    );
  }

}
