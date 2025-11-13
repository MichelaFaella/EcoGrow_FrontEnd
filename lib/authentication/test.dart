import 'dart:math' as math;
import 'package:Ecogrow/authentication/widgets/questions.dart';
import 'package:flutter/material.dart';
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
  static const double _tiltTurns = _tiltDegrees / 360.0; // per RotationTransition

  final List<QuestionData> _questions = [
    QuestionData(
      id: 'q1',
      title: 'QUESTION 01',
      question: 'When do you prefer to take care of your plants?',
      options: [
        'Weekdays only',
        'Weekends only',
        'Any day is fine',
        'Every other day',
      ],
    ),
    QuestionData(
      id: 'q2',
      title: 'QUESTION 02',
      question: 'At what time of day are you usually available?',
      options: [
        'Morning (7:00–10:00)',
        'Lunch break (12:00–14:00)',
        'Evening (18:00–21:00)',
        'I don\'t care',
      ],
    ),
    QuestionData(
      id: 'q3',
      title: 'QUESTION 03',
      question: 'How strict should reminders be?',
      options: [
        'Very strict, no changes',
        'Within a time window',
        'Flexible day',
        'No reminders',
      ],
    ),
    QuestionData(
      id: 'q4',
      title: 'QUESTION 04',
      question: 'When do you prefer to take care of your plants?',
      options: [
        'Weekdays only',
        'Weekends only',
        'Any day is fine',
        'Every other day',
      ],
    ),
    QuestionData(
      id: 'q5',
      title: 'QUESTION 05',
      question: 'When do you prefer to take care of your plants?',
      options: [
        'Weekdays only',
        'Weekends only',
        'Any day is fine',
        'Every other day',
      ],
    ),
    QuestionData(
      id: 'q6',
      title: 'QUESTION 06',
      question: 'When do you prefer to take care of your plants?',
      options: [
        'Weekdays only',
        'Weekends only',
        'Any day is fine',
        'Every other day',
      ],
    ),
    QuestionData(
      id: 'q7',
      title: 'QUESTION 07',
      question: 'When do you prefer to take care of your plants?',
      options: [
        'Weekdays only',
        'Weekends only',
        'Any day is fine',
        'Every other day',
      ],
    ),
    QuestionData(
      id: 'q8',
      title: 'QUESTION 08',
      question: 'When do you prefer to take care of your plants?',
      options: [
        'Weekdays only',
        'Weekends only',
        'Any day is fine',
        'Every other day',
      ],
    ),
  ];

  int _currentIndex = 0;
  String? _selectedOption;
  bool _isAnimating = false;
  bool _isForward = true;

  final Map<String, String> _answers = {};

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

    // di default la prossima card è inclinata di -8.7°
    _nextCardTurns = const AlwaysStoppedAnimation<double>(_tiltTurns);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  QuestionData get _currentQuestion => _questions[_currentIndex];

  double get _progress => (_currentIndex + 1) / _questions.length;

  void _onOptionSelected(String? value) {
    setState(() {
      _selectedOption = value;
    });
  }

  Future<void> _onNext() async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona una risposta prima di continuare'),
        ),
      );
      return;
    }
    if (_isAnimating) return;

    _answers[_currentQuestion.id] = _selectedOption!;

    if (_currentIndex == _questions.length - 1) {
      debugPrint('ANSWERS: $_answers');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Questionario completato')),
      );
      return;
    }

    setState(() {
      _isAnimating = true;
      _isForward = true;

      final curved = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );

      // card corrente SCENDE
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0, 1.2),
      ).animate(curved);

      // la PROSSIMA card ruota da inclinata (-8.7°) a dritta (0°)
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

      // nuova "prossima" card torna inclinata di default
      _nextCardTurns = const AlwaysStoppedAnimation<double>(_tiltTurns);
      _slideAnimation =
      const AlwaysStoppedAnimation<Offset>(Offset.zero);
    });
  }

  Future<void> _onBack() async {
    if (_isAnimating) return;
    if (_currentIndex == 0) return;

    setState(() {
      _currentIndex--;
      _selectedOption = _answers[_questions[_currentIndex].id];
      _isAnimating = true;
      _isForward = false;

      final curved = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );

      // la card precedente RISALe dal basso
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1.2),
        end: Offset.zero,
      ).animate(curved);

      // andando indietro NON tocchiamo la rotazione delle card dietro
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

  @override
  Widget build(BuildContext context) {
    final Animation<Offset> effectiveSlide = _isAnimating
        ? _slideAnimation
        : const AlwaysStoppedAnimation<Offset>(Offset.zero);

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
                    'Answer a few quick questions to tailor reminders to\n your routine.',
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
                    // 1) TUTTE le card dietro la corrente: stessa inclinazione, stessa posizione
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

                    // 2) Card immediatamente dietro la corrente:
                    //    - a riposo: inclinata come le altre (tutte -8.7°)
                    //    - durante NEXT: ruota velocemente a 0°
                    if (_currentIndex + 1 < _questions.length)
                      RotationTransition(
                        turns: _nextCardTurns,
                        child: QuestionCard(
                          title: _questions[_currentIndex + 1].title,
                          question:
                          _questions[_currentIndex + 1].question,
                          options:
                          _questions[_currentIndex + 1].options,
                          selectedOption: null,
                          onOptionSelected: (_) {},
                          onNext: () {},
                          onBack: null,
                          isLast:
                          _currentIndex + 1 == _questions.length - 1,
                          progress:
                          (_currentIndex + 2) / _questions.length,
                          isBehind: true,
                        ),
                      ),

                    // 3) Card corrente: unica dritta, animata in slide
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
