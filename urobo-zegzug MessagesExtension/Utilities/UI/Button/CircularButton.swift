import SwiftUI

struct CircularButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            SwiftUI.Circle()
                .frame(width: Constants.helpButtonSize, height: Constants.helpButtonSize)
                .foregroundColor(.gray)
                .shadow(color: .black, radius: .zero, x: Constants.helpButtonShadowOffset, y: Constants.helpButtonShadowOffset)
                .overlay {
                    configuration.label
                        .foregroundColor(.foreground)
                }
        }
    }
}

extension CircularButton {
    private enum Constants {
        static let helpButtonSize: CGFloat = 30
        static let helpButtonShadowOffset: CGFloat = 3
    }
}
