import 'dart:math' as math;
import 'package:Ecogrow/authentication/service/auth_service.dart';
import 'package:Ecogrow/dashboard/dashboard_page.dart';
import 'package:Ecogrow/utility/storage_service.dart';
import 'package:flutter/material.dart';

import 'package:Ecogrow/authentication/widgets/questions.dart';
import '../utility/app_colors.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class QuestionData {
  final String id;
  final String title;
  final String question;
  final List<String> options;

  QuestionData({
    required this.id,
    required this.title,
    required this.question,
    required this.options,
  });
}

class _TestPageState extends State<TestPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _nextCardTurns;

  static const double _tiltDegrees = -8.7;
  static final double _tiltRadians = _tiltDegrees * math.pi / 180.0;
  static const double _tiltTurns = _tiltDegrees / 360.0;

  final AuthService _authService = AuthService();

  List<QuestionData> _questions = [];
  int _currentIndex = 0;
  String? _selectedOption;
  bool _isAnimating = false;

  final Map<String, String> _answers = {};
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(curved);

    _nextCardTurns = const AlwaysStoppedAnimation<double>(_tiltTurns);

    _loadQuestionsFromBackend();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  QuestionData get _currentQuestion => _questions[_currentIndex];

  double get _progress =>
      _questions.isEmpty ? 0.0 : (_currentIndex + 1) / _questions.length;

  // ======================
  // LOAD QUESTIONS
  // ======================
  Future<void> _loadQuestionsFromBackend() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    final (ok, message, rawQuestions) =
    await _authService.fetchQuestionnaireQuestions();

    if (!mounted) return;

    if (!ok) {
      setState(() {
        _isLoading = false;
        _loadError = message ?? 'Errore nel caricamento del questionario.';
      });
      return;
    }

    final List<QuestionData> loaded = [];
    _answers.clear();

    for (int i = 0; i < rawQuestions.length; i++) {
      final q = rawQuestions[i];
      if (q is! Map<String, dynamic>) continue;

      final String id = q['id']?.toString() ?? '';
      final String text = q['text']?.toString() ?? '';
      final List<String> opts =
      ((q['options'] as List?) ?? []).map((o) => o.toString()).toList();

      loaded.add(
        QuestionData(
          id: id,
          title: 'QUESTION ${(i + 1).toString().padLeft(2, "0")}',
          question: text,
          options: opts,
        ),
      );
    }

    setState(() {
      _questions = loaded;
      _isLoading = false;
      _currentIndex = 0;
      _selectedOption =
      _questions.isNotEmpty ? _answers[_questions[0].id] : null;
    });
  }

  // =========================
  // SELEZIONE
  // =========================
  void _onOptionSelected(String? value) {
    setState(() {
      _selectedOption = value;
    });
  }

  // =========================
  // SUBMIT FINAL ANSWERS
  // =========================
  Future<void> _submitAnswersToBackend() async {
    final Map<String, String> payload = {};

    for (final q in _questions) {
      final selected = _answers[q.id];
      if (selected == null) continue;

      final idx = q.options.indexOf(selected);
      if (idx >= 0) {
        payload[q.id] = (idx + 1).toString();
      }
    }

    final (ok, message) =
    await _authService.submitQuestionnaireAnswers(payload);

    if (!mounted) return;

    if (ok) {
      // 👉 SALVO IL FLAG GLOBALE: questionario completato
      await StorageService.setQuestionnaireDone(true);

      // 👉 NAVIGO ALLA DASHBOARD
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Errore nel salvataggio delle risposte'),
        ),
      );
    }
  }

  // =========================
  // NEXT
  // =========================
  Future<void> _onNext() async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una risposta prima di continuare')),
      );
      return;
    }
    if (_isAnimating) return;

    _answers[_currentQuestion.id] = _selectedOption!;

    if (_currentIndex == _questions.length - 1) {
      await _submitAnswersToBackend();
      return;
    }

    setState(() {
      _isAnimating = true;

      final curved = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );

      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0, 1.2),
      ).animate(curved);

      _nextCardTurns = Tween<double>(
        begin: _tiltTurns,
        end: 0.0,
      ).animate(curved);
    });

    await _controller.forward();
    _controller.reset();

    setState(() {
      _currentIndex++;
      _selectedOption = _answers[_questions[_currentIndex].id];
      _isAnimating = false;

      _nextCardTurns = const AlwaysStoppedAnimation<double>(_tiltTurns);
      _slideAnimation =
      const AlwaysStoppedAnimation<Offset>(Offset.zero);
    });
  }

  // =========================
  // BACK
  // =========================
  Future<void> _onBack() async {
    if (_isAnimating || _currentIndex == 0) return;

    setState(() {
      _currentIndex--;
      _selectedOption = _answers[_questions[_currentIndex].id];
      _isAnimating = true;

      final curved = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1.2),
        end: Offset.zero,
      ).animate(curved);

      _nextCardTurns = const AlwaysStoppedAnimation<double>(_tiltTurns);
    });

    await _controller.forward();
    _controller.reset();

    setState(() {
      _isAnimating = false;
      _slideAnimation =
      const AlwaysStoppedAnimation<Offset>(Offset.zero);
    });
  }

  // ========= UI =========
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadQuestionsFromBackend,
                  child: const Text('Riprova'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: Text(
            'Nessuna domanda disponibile.',
            style: TextStyle(color: AppColors.white, fontSize: 16),
          ),
        ),
      );
    }

    final Animation<Offset> effectiveSlide =
    _isAnimating ? _slideAnimation : const AlwaysStoppedAnimation<Offset>(Offset.zero);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Care Preferences',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Help us create the best care schedule for you and your plants. '
                    'Answer a few quick questions to tailor reminders to your routine.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                height: 450,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (int i = _questions.length - 1;
                    i > _currentIndex + 1;
                    i--)
                      Transform.rotate(
                        angle: _tiltRadians,
                        alignment: Alignment.center,
                        child: QuestionCard(
                          title: _questions[i].title,
                          question: _questions[i].question,
                          options: _questions[i].options,
                          selectedOption: null,
                          onOptionSelected: (_) {},
                          onNext: () {},
                          onBack: null,
                          isLast: i == _questions.length - 1,
                          progress: (i + 1) / _questions.length,
                          isBehind: true,
                        ),
                      ),

                    if (_currentIndex + 1 < _questions.length)
                      RotationTransition(
                        turns: _nextCardTurns,
                        child: QuestionCard(
                          title: _questions[_currentIndex + 1].title,
                          question: _questions[_currentIndex + 1].question,
                          options: _questions[_currentIndex + 1].options,
                          selectedOption: null,
                          onOptionSelected: (_) {},
                          onNext: () {},
                          onBack: null,
                          isLast: _currentIndex + 1 == _questions.length - 1,
                          progress: (_currentIndex + 2) / _questions.length,
                          isBehind: true,
                        ),
                      ),

                    SlideTransition(
                      position: effectiveSlide,
                      child: QuestionCard(
                        title: _currentQuestion.title,
                        question: _currentQuestion.question,
                        options: _currentQuestion.options,
                        selectedOption: _selectedOption,
                        onOptionSelected: _onOptionSelected,
                        onNext: _onNext,
                        onBack: _currentIndex == 0 ? null : _onBack,
                        isLast: _currentIndex == _questions.length - 1,
                        progress: _progress,
                        isBehind: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
