import Foundation

final class MenuViewModel {
    var delegate: MenuViewModelDelegate?

    func startUrobo() {
        delegate?.startUrobo()
    }

    func startZegZug() {
        delegate?.startZegZug()
    }
}

protocol MenuViewModelDelegate {
    func startUrobo()
    func startZegZug()
}
