import 'package:flutter/material.dart';
import 'package:Ecogrow/utility/app_colors.dart';

class FriendsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String ownerName;      // se "" → non viene mostrato
  final ImageProvider image;
  final VoidCallback? onTap;

  const FriendsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ownerName,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasOwner = ownerName.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.light_gray,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.dark_gray,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Immagine a sinistra
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: SizedBox(
                  width: 90,
                  height: double.infinity,
                  child: Image(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Testi centrali
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Owner → solo se condivisa
                    if (hasOwner)
                      Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            size: 16,
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              ownerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: AppColors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Icona a destra (rimane uguale, la userai per share/unshare)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      ownerName.trim().isEmpty
                          ? Icons.person_add_alt_1_rounded   // <-- PIANTA PRIVATA → AGGIUNGI
                          : Icons.person_off_rounded,        // <-- PIANTA CONDIVISA → RIMUOVI
                      size: 32,
                      color: ownerName.trim().isEmpty
                          ? AppColors.green                   // aggiungi → verde
                          : AppColors.red,                    // rimuovi → rosso
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

