import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../utility/app_colors.dart';

class CustomBottomBar extends StatefulWidget {
  final int selectedIndex;
  final Future<void> Function(int) onItemSelected;

  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  final List<IconData> _icons = const [
    Symbols.potted_plant,
    Symbols.notifications,
    Symbols.add,
    Symbols.stethoscope,
    Symbols.person,
  ];

  bool _isAnimating = false;

  Future<void> _handleTap(int index) async {
    if (_isAnimating) return;
    _isAnimating = true;
    try {
      await widget.onItemSelected(index);
    } finally {
      _isAnimating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 335,
        height: 65,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / _icons.length;
            const indicatorSize = 48.0;

            final double targetLeft =
                (itemWidth * widget.selectedIndex) + (itemWidth - indicatorSize) / 2;

            return Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300), // leggermente più veloce
                  curve: Curves.easeInOutCubic,
                  left: targetLeft.clamp(0.0, constraints.maxWidth - indicatorSize),
                  top: (constraints.maxHeight - indicatorSize) / 2,
                  child: Container(
                    width: indicatorSize,
                    height: indicatorSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(_icons.length, (index) {
                    final bool isSelected = widget.selectedIndex == index;

                    return SizedBox(
                      width: itemWidth,
                      height: constraints.maxHeight,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => _handleTap(index),
                          child: AnimatedScale(
                            scale: isSelected ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOut,
                            child: Icon(
                              _icons[index],
                              color: isSelected ? Color(0xFF322f30) : AppColors.white,
                              size: isSelected ? 26 : 24,
                              fill: 1.0,
                              weight: 700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
