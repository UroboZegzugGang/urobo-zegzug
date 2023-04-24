import SwiftUI

struct MonochromeShadowButton: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        MonoButton(configuration: configuration)
    }

    private struct MonoButton: View {
        let configuration: ButtonStyle.Configuration
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.isEnabled) private var isEnabled: Bool

        var body: some View {
            configuration.label
                .font(.system(size: Constants.fontSize, weight: .bold))
                .frame(maxWidth: .infinity, maxHeight: Constants.height)
                .foregroundColor(
                    isEnabled ? (colorScheme == .light ? .white : .black) : .gray
                )
                .background {
                    Group {
                        Color.monochromeButton
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .stroke(
                                colorScheme == .light ? .black : .white,
                                lineWidth: Constants.borderWidth
                            )
                    }
                }
                .cornerRadius(Constants.cornerRadius)
                .shadow(color: .black, radius: .zero, x: Constants.shadowOffset, y: Constants.shadowOffset)
                .scaleEffect(configuration.isPressed ? Constants.tappedStateScaleValue : 1)
                .animation(.easeIn(duration: Constants.animationDuration), value: configuration.isPressed)
                .animation(.easeIn(duration: Constants.animationDuration), value: isEnabled)
                .padding()
                .padding(.horizontal)
        }
    }
}

extension MonochromeShadowButton {
    private enum Constants {
        static let fontSize: CGFloat = 20
        static let height: CGFloat = 50
        static let cornerRadius: CGFloat = 10
        static let borderWidth: CGFloat = 3
        static let shadowOffset: CGFloat = 5
        static let tappedStateScaleValue: CGFloat = 1.1
        static let animationDuration: CGFloat = 0.1
    }
}
