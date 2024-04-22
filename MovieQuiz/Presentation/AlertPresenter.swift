import Foundation
import UIKit

final class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    init(delegate: AlertPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    func showAlert(controller: UIViewController, alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: alertModel.buttonTexts,
            style: .default) { _ in
                alertModel.completions()
                
            }   
        alert.view.accessibilityIdentifier = "Game results"
        alert.addAction(action)
//        delegate?.showAlert(alert: alert)//changed
        controller.present(alert, animated: true, completion: nil)
    }
}
