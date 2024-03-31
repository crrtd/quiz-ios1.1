import Foundation
import UIKit

final class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    
    static func makeAlert(correct: Int, total: Int, message: String) -> AlertModel {
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть еще раз")
        
        return alertModel
    }
}
