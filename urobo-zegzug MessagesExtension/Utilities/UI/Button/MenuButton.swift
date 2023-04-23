import SwiftUI

struct ScaleOnTap: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? Constants.tappedStateScaleValue : 1)
            .animation(.easeIn(duration: Constants.animationDuration), value: configuration.isPressed)
    }
}

extension ScaleOnTap {
    private enum Constants {
        static let tappedStateScaleValue: CGFloat = 1.2
        static let animationDuration: CGFloat = 0.1
    }
}
