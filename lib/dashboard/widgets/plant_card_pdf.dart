import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../utility/app_colors.dart';
import '../pages/models/plant.dart';

class PlantCardPdf extends StatefulWidget {
  final Plant plant;

  /// callback verso il padre (true = selezionata, false = deselezionata, + bytes immagine)
  final void Function(bool isSelected, Uint8List? imageBytes)? onSelected;

  const PlantCardPdf({
    Key? key,
    required this.plant,
    this.onSelected,
  }) : super(key: key);

  @override
  State<PlantCardPdf> createState() => _PlantCardPdfState();
}

class _PlantCardPdfState extends State<PlantCardPdf> {
  bool selected = false;
  Uint8List? _imageBytes;

  @override
  Widget build(BuildContext context) {
    // ---------- LOAD IMAGE ----------
    Widget imageWidget;

    if (widget.plant.imageBase64 != null &&
        widget.plant.imageBase64!.isNotEmpty) {
      try {
        _imageBytes = base64Decode(widget.plant.imageBase64!);
        imageWidget = Image.memory(
          _imageBytes!,
          width: double.infinity,
          height: 162,
          fit: BoxFit.cover,
        );
      } catch (_) {
        _imageBytes = null;
        imageWidget = Container(
          width: double.infinity,
          height: 162,
          color: Colors.grey.shade300,
        );
      }
    } else {
      _imageBytes = null;
      imageWidget = Container(
        width: double.infinity,
        height: 162,
        color: Colors.grey.shade300,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.light_gray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: double.infinity,
                  height: 165,
                  child: imageWidget,
                ),
              ),

              // ---------- SELECTABLE SQUARE ----------
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selected = !selected;
                    });

                    // notifico il padre con stato + bytes immagine
                    widget.onSelected?.call(selected, _imageBytes);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 26,
                    width: 26,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.green : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected ? AppColors.white : Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 18,
                      color: selected ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // NAME
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.plant.commonName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
