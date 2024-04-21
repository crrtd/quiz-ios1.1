import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFacotryDelegate {
    
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    
    //MARK: - init
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    //MARK: - func didLoadDataFromServer
    func didLoadDataFromServer() {
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
       
    //MARK: - func didFailToLoadData
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    //MARK: - func restartGame
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    //MARK: - func isLastQuestion
    private func isLastQuiestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    //MARK: - func resetQuestionIndex
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    //MARK: - func switchToNextQuestion
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    //MARK: - func convert(model: )
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel (
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    //MARK: - func didAnswer
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    //MARK: - func yesButtonClicked
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    //MARK: - func noButtonClicked
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    //MARK: - func didReceiveNextQuestion
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    //MARK: - func makeResultMessage
    private func makeResultMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfo = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let resultMessage = [currentGameResultLine, totalPlaysCountLine, bestGameInfo, averageAccuracyLine].joined(separator: "\n")
        return resultMessage
    }
    
    //MARK: - func showNextQuestionOrResults
      private func proceedToNextQuestionOrResults() {
          if self.isLastQuiestion() {
              
              let text = makeResultMessage()
              
              let viewModel = AlertModel(
                  title: "Этот раунд окончен!",
                  message: text,
                  buttonTexts: "Сыграть еще раз",
                  completions: { [weak self] in
                      self?.restartGame()
                  }
              )
              
              viewController?.show(quiz: viewModel)
          } else {
              self.switchToNextQuestion()
              questionFactory?.requestNextQuestion()
          }
      }
    
    //MARK: - func proceedWithAnswer
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
}

