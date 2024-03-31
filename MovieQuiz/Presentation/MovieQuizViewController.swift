import UIKit

final class MovieQuizViewController: UIViewController, QuestionFacotryDelegate, AlertPresenterDelegate {
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var alertModel: AlertModel?
    private let alertPresenter = AlertPresenter()
    private var statisticService: StatisticService = StatisticServiceImplementation()

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter.delegate = self
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()

        imageView.layer.cornerRadius = 20
        
        alertPresenter.delegate = self
        
//        print(NSHomeDirectory()) //файлы которые лежат в приложении
//        UserDefaults.standard.set(true, forKey: "viewDidLoad")
//        print(Bundle.main.bundlePath) //адрес где хранится само приложение
    }

    //MARK: - func yesButtonClicked
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        guard let currentQuestion = currentQuestion else { return }
                
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    //MARK: - func noButtonClicked
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    //MARK: - func didReceiveNextQuestion
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    //MARK: - func convert(model: ... )
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel (
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    //MARK: - func show(quiz step: ... )
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //MARK: - func showAnswerResult
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ysGreen.cgColor : UIColor.ysRed.cgColor
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.showNextQuestionOrResults()
        }
        
    }

    //MARK: - func displayAlert
    func displayAlert(alertModel result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            questionFactory.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }

    //MARK: - func showNextQuestionOrResults
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let text = "Ваш результат; \(String(correctAnswers))" + "/10" + "\n" + "Количество сыгранных квизов: \(statisticService.gamesCount)" + "\n" + "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total)(\(statisticService.bestGame.date.dateTimeString))" + "\n" + "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            alertModel = AlertPresenter.makeAlert(correct: correctAnswers, total: questionsAmount, message: text)
            guard let alertModel = alertModel else { return }
            
            self.displayAlert(alertModel: alertModel)
            
        } else {
            currentQuestionIndex += 1

            self.questionFactory.requestNextQuestion()
        }
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
}
