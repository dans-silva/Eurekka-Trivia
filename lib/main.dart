import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eurekka_trivia/models/question.dart';
import 'package:eurekka_trivia/services/trivia_service.dart';
import 'package:eurekka_trivia/widgets/custom_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eurekka Trivia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/eurekka_logo.png', height: 200),
            SizedBox(height: 1),
            CustomButton(
              text: 'Iniciar',
              icon: Icons.arrow_forward,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CategoryScreen()));
              },
              buttonColor: const Color(0xFFF97316),
              borderRadius: 4.0,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Futebol', 'icon': '⚽', 'id': 21},
    {'name': 'Jogos', 'icon': '🎮', 'id': 15},
    {'name': 'Filmes e Séries', 'icon': '🎬', 'id': 11},
    {'name': 'Conhecimentos Gerais', 'icon': '🧠', 'id': 9},
    {'name': 'Música', 'icon': '🎵', 'id': 12},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Centraliza horizontalmente
        children: [
          SizedBox(height: 40),
          Text(
            'Escolha uma categoria para jogar!',
            style: TextStyle(
              fontSize: 44,
            ),
            textAlign: TextAlign
                .center, // 1. Centraliza o texto dentro do espaço disponível
            softWrap:
                true, // 2. Permite quebra de linha (opcional, já é true por padrão)
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD78C),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: ListTile(
                    leading: Text(categories[index]['icon'],
                        style: TextStyle(fontSize: 24)),
                    title: Text(
                      categories[index]['name'],
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuestionScreen(
                              categoryId: categories[index]['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionScreen extends StatefulWidget {
  final int categoryId;

  QuestionScreen({required this.categoryId});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  double timerPercent = 0.0;
  int timerSeconds = 30;
  Timer? timer;
  late List<String> currentAnswers;
  bool timeUp = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    startTimer();
  }

  Future<void> fetchQuestions() async {
    final fetchedQuestions =
        await TriviaService.fetchQuestions(widget.categoryId);
    setState(() {
      questions = fetchedQuestions;
      _shuffleAnswers();
    });
  }

  void _shuffleAnswers() {
    if (questions.isNotEmpty) {
      currentAnswers = [
        ...questions[currentQuestionIndex].incorrectAnswers,
        questions[currentQuestionIndex].correctAnswer
      ]..shuffle();
    }
  }

  void startTimer() {
    timer?.cancel();
    timerSeconds = 5;
    timerPercent = 0.0;
    timeUp = false;
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (timer) {
      if (mounted) {
        setState(() {
          if (timerSeconds > 0 && !isAnswered) {
            timerSeconds--;
            timerPercent = 1 - (timerSeconds / 5);
            if (timerSeconds == 0) {
              timeUp = true;
              timer.cancel();
            }
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void checkAnswer(String selectedAnswer) {
    if (!isAnswered && !timeUp) {
      setState(() {
        isAnswered = true;
        if (selectedAnswer == questions[currentQuestionIndex].correctAnswer) {
          score++;
        }
      });
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        timeUp = false;
        _shuffleAnswers();
        startTimer();
      });
    } else {
      timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                ResultScreen(score: score, total: questions.length)),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty)
      return Scaffold(body: Center(child: CircularProgressIndicator()));

    final question = questions[currentQuestionIndex];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 40),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC75D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  question.question,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: currentAnswers.length,
                itemBuilder: (context, index) {
                  final answer = currentAnswers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (states) {
                              if (!isAnswered && !timeUp)
                                return const Color(0xFFFFD78C); // #FFD78C;
                              if (isAnswered &&
                                  answer == question.correctAnswer)
                                return const Color(0xFFD0FECF);
                              if (isAnswered) return const Color(0xFFFFAFAF);
                              return const Color(0xFFFFD78C); // Fallback
                            }),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          onPressed: (isAnswered || timeUp)
                              ? null
                              : () => checkAnswer(answer),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              answer,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    10.0), // Aumentado para 10.0 para maior visibilidade
                child: Container(
                  height: 10,
                  child: LinearProgressIndicator(
                    value: timerPercent,
                    backgroundColor: const Color(0xFFFFD78C),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(const Color(0xFFF97316)),
                  ),
                ),
              ),
            ),
            if (isAnswered || timeUp)
              Padding(
                padding:
                    const EdgeInsets.only(right: 16.0, top: 16.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    text: 'Próximo',
                    icon: Icons.arrow_forward,
                    onPressed: nextQuestion,
                    borderRadius: 8.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  ResultScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              score < total ? 'Você pode melhorar!' : 'Parabéns!',
              style: TextStyle(fontSize: 24, color: Colors.orange),
            ),
            SizedBox(height: 20),
            Text('Você acertou $score perguntas',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            CustomButton(
              text: 'Jogar novamente',
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => SplashScreen()));
              },
              buttonColor: const Color(0xFFFFC75D), // #FFC75D
              borderRadius: 8.0,
              textColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
