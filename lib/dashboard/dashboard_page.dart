import 'package:Ecogrow/dashboard/pages/camera.dart';
import 'package:Ecogrow/dashboard/pages/garden.dart';
import 'package:Ecogrow/dashboard/pages/profile.dart';
import 'package:Ecogrow/dashboard/widgets/custom_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onItemTapped(int index) async {
    final int current = _pageController.page?.round() ?? _selectedIndex;

    // Se la distanza tra le pagine è maggiore di 1, salta direttamente
    if ((index - current).abs() > 1) {
      _pageController.jumpToPage(index);
    } else {
      // Altrimenti esegui una breve animazione
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOutCubic,
      );
    }
  }


  bool _onScrollNotification(ScrollNotification n) {
    if (n is ScrollEndNotification) {
      final int settled = _pageController.page?.round() ?? _selectedIndex;
      if (settled != _selectedIndex) {
        setState(() => _selectedIndex = settled);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final baseTheme = Theme.of(context);
    final forcedTextTheme = baseTheme.textTheme.apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      // Lo Stack tiene la bottom bar sopra il contenuto, ma senza coprire
      body: Theme(
        data: baseTheme.copyWith(textTheme: forcedTextTheme),
        child: Stack(
          children: [
            // Contenuto principale (pagine)
            NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                children: const [
                  GardenPage(),
                  _PageContent(title: 'Notifications Page'),
                  CameraPage(),
                  _PageContent(title: 'Health Page'),
                  ProfilePage(),
                ],
              ),
            ),

            // Bottom bar in overlay, ma trasparente verso l’alto
            if(_selectedIndex != 2)
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  ignoring: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: SizedBox(
                      height: 100.0,
                      child: CustomBottomBar(
                        selectedIndex: _selectedIndex,
                        onItemSelected: _onItemTapped,
                      ),
                    ),
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final String title;
  const _PageContent({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
