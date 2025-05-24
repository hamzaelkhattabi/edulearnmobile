import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/quiz_models.dart'; // Ajustez le chemin
import 'quiz_screen.dart';            // Ajustez le chemin

// Couleurs
const Color primaryAppColor = Color(0xFFF45B69);
const Color textDarkColor = Color(0xFF1F2024);
const Color lightBackground = Color(0xFFF9FAFC);
const Color cardBackgroundColor = Colors.white;

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  // Données factices pour la liste des quiz
  // Dans une vraie app, cela viendrait d'une base de données ou d'une API
  List<Quiz> _getAvailableQuizzes() {
    return [
      Quiz( // SampleQuiz1 (celui de Python)
        id: "python_basics_01",
        title: "Bases de Python - Quiz 1",
        description: "Testez vos connaissances fondamentales sur Python avec 3 questions.",
        questions: [ /* ... Définissez les questions comme dans l'exemple précédent ... */
          QuizQuestion(id: "q_py_1", questionText: "Mot-clé fonction Python ?", type: QuestionType.singleChoice, options: [QuizOption(id:"o1", text:"def", isCorrect: true), /*...*/], explanation:"..."),
          QuizQuestion(id: "q_py_2", questionText: "Types numériques Python ? (multi)", type: QuestionType.multipleChoice, options: [QuizOption(id:"o_py_int", text:"int", isCorrect:true), QuizOption(id:"o_py_str", text:"string"), /*...*/], explanation:"..."),
          QuizQuestion(id: "q_py_3", questionText: "Liste Python immuable ?", type: QuestionType.trueFalse, options: [QuizOption(id:"o_tf_1", text:"Faux", isCorrect:true), QuizOption(id:"o_tf_2", text:"Vrai")], explanation:"..."),
        ],
      ),
      Quiz( // SampleQuiz2
        id: "flutter_widgets_01",
        title: "Widgets Flutter - Quiz 1",
        description: "Connaissez-vous bien les widgets de base de Flutter ? 2 questions.",
        questions: [
          QuizQuestion(
            id: "q_fl_1",
            questionText: "Quel widget est utilisé pour afficher une simple chaîne de texte ?",
            type: QuestionType.singleChoice,
            options: [
              QuizOption(id: "fl_o1", text: "Container"),
              QuizOption(id: "fl_o2", text: "Text", isCorrect: true),
              QuizOption(id: "fl_o3", text: "Row"),
            ],
            explanation: "Le widget 'Text' est utilisé pour afficher du texte à l'écran."
          ),
          QuizQuestion(
            id: "q_fl_2",
            questionText: "`StatelessWidget` peut changer son propre état interne après sa construction.",
            type: QuestionType.trueFalse,
            options: [
              QuizOption(id: "fl_tf1", text: "Vrai"),
              QuizOption(id: "fl_tf2", text: "Faux", isCorrect: true),
            ],
            explanation: "Les `StatelessWidget` sont immuables après leur création. Pour un état mutable, utilisez `StatefulWidget`."
          ),
        ],
      ),
      // ... Ajoutez d'autres quiz ici ...
    ];
  }

  @override
  Widget build(BuildContext context) {
    final availableQuizzes = _getAvailableQuizzes();

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: cardBackgroundColor,
        elevation: 0.5,
        title: Text(
          "Liste des Quiz",
          style: GoogleFonts.poppins(color: textDarkColor, fontWeight: FontWeight.w600),
        ),
        // Vous pourriez ajouter un bouton retour si cette page n'est pas une racine de navigation
        // leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDarkColor), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: availableQuizzes.length,
        itemBuilder: (context, index) {
          final quiz = availableQuizzes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              leading: CircleAvatar(
                backgroundColor: primaryAppColor.withOpacity(0.15),
                child: Icon(Icons.quiz_outlined, color: primaryAppColor),
              ),
              title: Text(
                quiz.title,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textDarkColor),
              ),
              subtitle: Text(
                quiz.description,
                style: GoogleFonts.poppins(fontSize: 13, color: textGreyColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: textGreyColor, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizScreen(quiz: quiz)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}