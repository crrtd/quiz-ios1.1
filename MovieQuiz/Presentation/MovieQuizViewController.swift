import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    private var presenter: MovieQuizPresenter!
    private let alertPresenter = AlertPresenter()
    
    //MARK: - @IBOutlets
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak internal var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak internal var yesButton: UIButton!
    @IBOutlet weak internal var noButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
        imageView.layer.cornerRadius = 20
    }
    
    //MARK: - func yesButtonClicked
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    //MARK: - func noButtonClicked
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    //MARK: - func didRecieveNextQuestion
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    //MARK: - func showLoadingIndicator
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    //MARK: - func hideLoadingIndicator
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    //MARK: - func showNetworkError
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonTexts: "Попробовать еще раз",
            completions: { [weak self] in
                self?.presenter.restartGame()
            })
        self.show(quiz: alertModel)
    }

    //MARK: - func highlightImageBorder
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ysGreen.cgColor : UIColor.ysRed.cgColor
    }
    

    //MARK: - func show(quiz step: ... )
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //MARK: - func show(quiz result: ... )
    func show(quiz result: AlertModel) {
        alertPresenter.showAlert(controller: self, alertModel: result)
    }
}

