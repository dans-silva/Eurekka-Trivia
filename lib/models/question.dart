class Question {
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  Question({
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question']
          .toString()
          .replaceAll('&quot;', '"')
          .replaceAll('&#039;', "'"),
      correctAnswer: json['correct_answer']
          .toString()
          .replaceAll('&quot;', '"')
          .replaceAll('&#039;', "'"),
      incorrectAnswers: List<String>.from(json['incorrect_answers'])
          .map((answer) =>
              answer.replaceAll('&quot;', '"').replaceAll('&#039;', "'"))
          .toList(),
    );
  }
}
