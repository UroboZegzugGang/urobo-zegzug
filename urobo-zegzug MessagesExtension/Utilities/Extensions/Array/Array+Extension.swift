import Foundation

extension Array {
    subscript (edge index: Int) -> Element {
        get {
            index % 12 == 0 ? self[index - 12] : self[index]
        }
        set(newValue) {
            self[index] = newValue
        }
    }
}
