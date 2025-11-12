import 'package:Ecogrow/utility/app_colors.dart';
import 'package:flutter/material.dart';

import '../widgets/plant_filter.dart';
import '../widgets/plant_grid.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({Key? key}) : super(key: key);

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  String selectedFilter = 'ALL';

  void _onFilterChanged(String newFilter) {
    setState(() {
      selectedFilter = newFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Container(
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.light_gray,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 12),
                      Icon(Icons.search,color: AppColors.dark_gray,),

                      Expanded(child: TextField(
                        cursorWidth: 0,
                        showCursor: false,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search your plants...',
                          hintStyle: TextStyle(
                            color: AppColors.dark_gray,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                        ),
                      ),),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Your plants",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              PlantFilterBar(onFilterSelected: _onFilterChanged),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: PlantGrid(filter: selectedFilter),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
