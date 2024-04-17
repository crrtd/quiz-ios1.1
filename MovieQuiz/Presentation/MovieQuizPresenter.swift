import Foundation
import UIKit

final class MovieQuizPresenter {
    var currentQuestionIndex: Int = 0
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    

    
    func isLastQuiestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel (
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        
        guard let currentQuestion = currentQuestion else { return }
                
        let givenAnswer = true
        
//        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
//
        guard let currentQuestion = currentQuestion else { return }
//
        let givenAnswer = false
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
//
//        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
}

