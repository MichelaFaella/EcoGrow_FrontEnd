import 'package:Ecogrow/utility/app_colors.dart';
import 'package:flutter/material.dart';

class PlantFilterBar extends StatefulWidget {
  final void Function(String)? onFilterSelected; // 👈 aggiunto callback

  const PlantFilterBar({Key? key, this.onFilterSelected}) : super(key: key);

  @override
  State<PlantFilterBar> createState() => _PlantFilterBarState();
}

class _PlantFilterBarState extends State<PlantFilterBar>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  final List<String> filters = ["ALL", "SIZE", "DIFFICULTY"];
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _onTap(int i) {
    if (i == selectedIndex) return;
    setState(() {
      selectedIndex = i;
      _controller.forward(from: 0);
    });

    // 👇 Notifica la GardenPage passando il filtro selezionato
    widget.onFilterSelected?.call(filters[i]);
  }

  double _xForIndex(int i, int n) => 2.0 * (i + 0.5) / n - 1.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = filters.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(n, (i) {
            final isSelected = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onTap(i),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      color: isSelected ? AppColors.green : AppColors.black,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: isSelected ? 15 : 14,
                      fontFamily: 'Poppins',
                      letterSpacing: 1.2,
                    ),
                    child: Text(filters[i]),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: 20,
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(height: 1, color: AppColors.black),
                ),
              ),
              AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  final x = _xForIndex(selectedIndex, n);
                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    alignment: Alignment(x, 0),
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.green.withOpacity(0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
