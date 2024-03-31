import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func displayAlert(alertModel result: AlertModel)
}
