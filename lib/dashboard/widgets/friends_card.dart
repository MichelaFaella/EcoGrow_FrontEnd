import 'package:flutter/material.dart';
import 'package:Ecogrow/utility/app_colors.dart';

class FriendsCard extends StatelessWidget {
  final String title;          // es. "Adiantum raddianum"
  final String subtitle;       // es. "“Fragrans”"
  final String ownerName;      // es. "Franco Farina"
  final ImageProvider image;   // es. AssetImage("images/plant1.jpg")
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
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
                  width: 80,
                  height: double.infinity,
                  child: Image(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Testi centrali
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titolo
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
                    // Sottotitolo
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
                    // Owner
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

              // Icona mute a destra
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_off_rounded,
                      size: 22,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
